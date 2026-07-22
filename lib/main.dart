import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/config/stripe_config.dart';
import 'core/di/app_providers.dart';
import 'core/di/service_locator.dart';
import 'core/local/token_manager.dart';
import 'core/routes/app_routes.dart';
import 'core/security/mock_location_guard.dart';
import 'core/theme/material_theme.dart';
import 'core/services/notification_service.dart';
import 'core/theme/theme_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.handleBackgroundMessage(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  if (kDebugMode) {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }
  FirebaseAuth.instance.setLanguageCode('es');
  await NotificationService.init(navigatorKey);
  sl.init();
  runApp(
    MultiProvider(
      providers: appProviders,
      child: const LogiRedApp(),
    ),
  );
}

class LogiRedApp extends StatelessWidget {
  const LogiRedApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'LogiRed',
      debugShowCheckedModeBanner: false,
      locale: const Locale('es'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
      ],
      theme: MaterialTheme(Typography.material2021().black).light(),
      darkTheme: MaterialTheme(Typography.material2021().white).dark(),
      themeMode: themeMode,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) => MockLocationGuard(child: child!),
      home: const AppStartup(),
    );
  }
}

class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final tokens = context.read<TokenManager>();
    await Permission.notification.request();
    final token = await tokens.getToken();
    final userType = await tokens.getUserType();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      await NotificationService.registerDeviceToken();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        userType == 2 ? AppRoutes.driverMain : AppRoutes.clientMain,
      );
      NotificationService.openPendingRoute();
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
