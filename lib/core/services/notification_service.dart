import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../di/service_locator.dart';

const _channelId = 'logired_main';
const _channelName = 'LogiRed';
const _primaryColor = Color(0xFF1D6B50);

final _localNotif = FlutterLocalNotificationsPlugin();

/// Tipos de push con los que administracion avisa un cambio de estado del
/// conductor. Llegan en `data['type']` junto con `reason` en los dos ultimos.
const _driverStatusTypes = {
  'driver_approved',
  'driver_rejected',
  'driver_blocked',
};

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;
  static GlobalKey<NavigatorState>? _navKey;
  static StreamSubscription<String>? _tokenRefreshSub;
  static String? _pendingRoute;

  /// Se incrementa cada vez que llega un push de cambio de estado del
  /// conductor. `DriverGate` lo escucha para releer `GET /users/me` y cambiar
  /// de pantalla sin que el usuario tenga que reiniciar la app.
  ///
  /// Se notifica el evento, no el estado: el push no es fuente de verdad, solo
  /// la señal de que hay que volver a preguntarle a la API.
  static final ValueNotifier<int> driverStatusRevision = ValueNotifier<int>(0);

  static void _checkDriverStatusChange(RemoteMessage msg) {
    final type = msg.data['type']?.toString();
    if (type != null && _driverStatusTypes.contains(type)) {
      driverStatusRevision.value++;
    }
  }

  static Future<void> init(GlobalKey<NavigatorState> navKey) async {
    _navKey = navKey;

    await _localNotif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onLocalTap,
    );

    final launch = await _localNotif.getNotificationAppLaunchDetails();
    final launchPayload = launch?.notificationResponse?.payload;
    if (launch?.didNotificationLaunchApp == true &&
        launchPayload != null &&
        launchPayload.isNotEmpty) {
      _pendingRoute = launchPayload;
    }

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Propuestas, viajes y actualizaciones de LogiRed',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          ledColor: _primaryColor,
          showBadge: true,
        ));

    FirebaseMessaging.onMessage.listen((msg) {
      _checkDriverStatusChange(msg);
      _showLocal(msg);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_onRemoteTap);

    final initial = await _fcm.getInitialMessage();
    if (initial != null) _onRemoteTap(initial);
  }

  static Future<void> registerDeviceToken() async {
    try {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('FCM: no se pudo obtener el token del dispositivo');
        return;
      }
      debugPrint('FCM token: $token');
      await _sendTokenToApi(token);
    } catch (e) {
      debugPrint('FCM: error al registrar el dispositivo: $e');
    } finally {
      _tokenRefreshSub ??= _fcm.onTokenRefresh.listen(_sendTokenToApi);
    }
  }

  static Future<void> _sendTokenToApi(String token) async {
    try {
      final res = await sl.apiService.registerDeviceToken({
        'fcm_token': token,
        'device_name': await _deviceName(),
      });
      debugPrint('FCM: token registrado en la API (${res.statusCode})');
    } catch (e) {
      debugPrint('FCM: fallo al enviar el token a la API: $e');
    }
  }

  static Future<String> _deviceName() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        final manufacturer = android.manufacturer.trim();
        final model = android.model.trim();
        final name =
            model.toLowerCase().startsWith(manufacturer.toLowerCase())
                ? model
                : '$manufacturer $model';
        if (name.trim().isNotEmpty) return name.trim();
      } else if (Platform.isIOS) {
        final ios = await info.iosInfo;
        if (ios.modelName.isNotEmpty) return ios.modelName;
      }
    } catch (e) {
      debugPrint('FCM: no se pudo leer el modelo del dispositivo: $e');
    }
    return Platform.isAndroid ? 'android' : 'ios';
  }

  static Future<void> handleBackgroundMessage(RemoteMessage msg) async {
    if (msg.notification != null) return;

    await _localNotif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    await _showLocal(msg);
  }

  static Future<void> _showLocal(RemoteMessage msg) async {
    final n = msg.notification;
    final title = n?.title ?? msg.data['title']?.toString() ?? '';
    final body = n?.body ?? msg.data['body']?.toString() ?? '';
    if (title.isEmpty && body.isEmpty) return;

    final route = msg.data['route'] as String?;

    await _localNotif.show(
      msg.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          color: _primaryColor,
          styleInformation: BigTextStyleInformation(
            body,
            htmlFormatBigText: false,
            contentTitle: title,
            htmlFormatContentTitle: false,
          ),
          showWhen: true,
          when: DateTime.now().millisecondsSinceEpoch,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: route,
    );
  }

  static void _onLocalTap(NotificationResponse r) => _navigate(r.payload);

  static void _onRemoteTap(RemoteMessage msg) {
    // Abrir la app desde el push tambien cuenta como señal: el estado pudo
    // cambiar mientras estaba cerrada.
    _checkDriverStatusChange(msg);
    _navigate(msg.data['route'] as String?);
  }

  static void _navigate(String? route) {
    if (route == null || route.isEmpty) return;
    final nav = _navKey?.currentState;
    if (nav == null) {
      _pendingRoute = route;
    } else {
      nav.pushNamed(route);
    }
  }

  static void openPendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    _navigate(route);
  }
}
