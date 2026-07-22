import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/local/token_manager.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/utils/car_marker.dart';
import '../../../../core/utils/directions.dart';
import '../../../../core/utils/payment_method.dart';
import '../../../../core/utils/ride_status.dart';
import '../../../../core/websocket/websocket_manager.dart';
import '../../../../core/widgets/slide_to_confirm.dart';
import '../../../../core/widgets/turn_banner.dart';
import '../../../main/widgets/driver_app_bar.dart';
import 'active_trip_provider.dart';

enum _NavPhase { toOrigin, atOrigin, toDestination }

class ActiveTripScreen extends StatefulWidget {
  final int tripId;
  final bool isDriver;
  final double proposalPrice;

  const ActiveTripScreen({
    super.key,
    required this.tripId,
    required this.isDriver,
    required this.proposalPrice,
  });

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  @override
  void initState() {
    super.initState();
    // Mantiene la pantalla encendida durante todo el viaje.
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (c) => ActiveTripProvider(c.read<ApiService>())
        ..load(widget.tripId, widget.isDriver, widget.proposalPrice),
      child: Consumer<ActiveTripProvider>(
        builder: (context, provider, _) {
          final colorScheme = Theme.of(context).colorScheme;
          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLow,
            appBar: const DriverAppBar(showBack: true),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.trip == null
                    ? Center(
                        child: Text(
                          provider.error ?? 'Error al cargar el viaje',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      )
                    : _NavBody(provider: provider, colorScheme: colorScheme),
          );
        },
      ),
    );
  }
}

class _NavBody extends StatefulWidget {
  final ActiveTripProvider provider;
  final ColorScheme colorScheme;
  const _NavBody({required this.provider, required this.colorScheme});

  @override
  State<_NavBody> createState() => _NavBodyState();
}

class _NavBodyState extends State<_NavBody> {
  GoogleMapController? _mapCtrl;
  StreamSubscription<Position>? _geoSub;
  StreamSubscription<CompassEvent>? _compassSub;

  _NavPhase _phase = _NavPhase.toOrigin;
  LatLng? _current;
  double _bearing = 0;
  double _speedKmh = 0;
  bool _follow = true;
  int _animCount = 0;
  DateTime? _lastBearingUpdate;
  String? _error;

  List<LatLng> _route = [];
  List<LatLng> _remaining = [];
  int _routeIndex = 0;
  List<NavStep> _steps = [];
  int _stepIndex = 0;
  String _stepDistanceText = '';
  String? _durationText;
  String? _distanceText;

  /// [_suffixMeters]\[i\] = metros desde _route[i] hasta el final; permite
  /// recalcular la distancia/tiempo restantes en cada fix sin recorrer todo.
  List<double> _suffixMeters = [];
  double _routeDistanceMeters = 0;
  double _routeDurationSecs = 0;

  final FlutterTts _tts = FlutterTts();
  bool _muted = false;
  int _spokenStep = -1;

  BitmapDescriptor? _carIcon;

  /// Rumbo real de avance del vehículo (curso GPS); orienta el ícono del carro.
  /// [_bearing] es el rumbo del dispositivo (brújula) que gira el mapa heading-up.
  double _travelBearing = 0;

  double? _lastLat, _lastLng;
  DateTime? _lastTime;
  final WebSocketManager _locWs = WebSocketManager();
  bool _publishing = false;

  double _offRouteMeters = 0;
  int _offRouteCount = 0;
  DateTime? _lastRouteFetch;
  bool _refetchingRoute = false;

  late final LatLng _origin =
      LatLng(widget.provider.trip!.originLat, widget.provider.trip!.originLng);
  late final LatLng _destination = LatLng(widget.provider.trip!.destinationLat,
      widget.provider.trip!.destinationLng);

  @override
  void initState() {
    super.initState();
    _phase = widget.provider.trip!.status == RideStatus.inProcess
        ? _NavPhase.toDestination
        : _NavPhase.toOrigin;
    _initTts();
    _setup();
    _startCompass();
    _buildCarIcon();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _geoSub?.cancel();
    _tts.stop();
    _locWs.disconnect();
    _mapCtrl?.dispose();
    super.dispose();
  }

  Future<void> _buildCarIcon() async {
    final icon = await buildCarMarker();
    if (!mounted) return;
    setState(() => _carIcon = icon);
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('es-MX');
      await _tts.setSpeechRate(0.5);
    } catch (_) {}
  }

  void _speak(String text) {
    if (_muted || text.isEmpty) return;
    _tts.stop();
    _tts.speak(text);
  }

  Future<void> _setup() async {
    final ok = await _ensurePermission();
    if (!ok) {
      if (mounted) setState(() => _error = 'Se necesita permiso de ubicación.');
      return;
    }
    await _connectPublish();
    try {
      final pos = await Geolocator.getCurrentPosition();
      _current = LatLng(pos.latitude, pos.longitude);
      _lastLat = pos.latitude;
      _lastLng = pos.longitude;
      _lastTime = DateTime.now();
    } catch (_) {}
    _geoSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 1),
    ).listen(_onPosition);
    await _loadRouteForPhase();
    if (mounted) setState(() {});
  }

  Future<bool> _ensurePermission() async {
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }

  Future<void> _connectPublish() async {
    if (_publishing) return;
    final token = await context.read<TokenManager>().getToken();
    if (token == null || token.isEmpty) return;
    final id = widget.provider.trip!.id;
    _locWs.connect('wss://api-logired.shop/ws/rides/$id/publish?token=$token');
    _publishing = true;
  }

  void _onPosition(Position pos) {
    final lat = pos.latitude, lng = pos.longitude;
    final now = DateTime.now();
    double? bearing;
    double? speedKmh;
    if (_lastLat != null && _lastLng != null && _lastTime != null) {
      final meters = Geolocator.distanceBetween(_lastLat!, _lastLng!, lat, lng);
      if (meters > 1) {
        bearing =
            (Geolocator.bearingBetween(_lastLat!, _lastLng!, lat, lng) + 360) %
                360;
        final dt = now.difference(_lastTime!).inMilliseconds / 1000.0;
        if (dt > 0) speedKmh = (meters / dt) * 3.6;
      }
    }
    _lastLat = lat;
    _lastLng = lng;
    _lastTime = now;
    _current = LatLng(lat, lng);
    _trimTraveledRoute();
    // El curso GPS orienta el sprite del carro; el mapa gira con la brújula.
    if (pos.speed > 0.3 && pos.heading >= 0 && pos.heading <= 360) {
      _travelBearing = pos.heading;
    } else if (bearing != null) {
      _travelBearing = bearing;
    }
    _speedKmh = (pos.speed.isFinite && pos.speed > 0)
        ? pos.speed * 3.6
        : (speedKmh ?? 0);

    _locWs.send(jsonEncode({
      'lat': lat,
      'lng': lng,
      if (bearing != null) 'bearing': bearing,
      if (speedKmh != null) 'speed': speedKmh,
    }));

    _updateStep();
    _updateRemainingEta();
    _maybeRecalcRoute();
    if (_follow && _phase != _NavPhase.atOrigin) {
      _guardedAnimate(CameraUpdate.newCameraPosition(CameraPosition(
          target: _current!, zoom: 18.5, tilt: 55, bearing: _bearing)));
    }
    if (mounted) setState(() {});
  }

  void _guardedAnimate(CameraUpdate u) {
    _animCount++;
    _mapCtrl?.animateCamera(u).whenComplete(() {
      if (mounted && _animCount > 0) _animCount--;
    });
  }

  double? _distanceToTarget(LatLng t) => (_lastLat == null || _lastLng == null)
      ? null
      : Geolocator.distanceBetween(
          _lastLat!, _lastLng!, t.latitude, t.longitude);

  void _trimTraveledRoute() {
    if (_current == null || _route.length < 2) {
      _remaining = _route;
      return;
    }
    final cur = _current!;
    int best = _routeIndex;
    double bestDist = double.infinity;
    final end = math.min(_route.length - 1, _routeIndex + 40);
    for (int i = _routeIndex; i <= end; i++) {
      final d = Geolocator.distanceBetween(
          cur.latitude, cur.longitude, _route[i].latitude, _route[i].longitude);
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    _routeIndex = best;
    _offRouteMeters = bestDist.isFinite ? bestDist : 0;
    final ahead = _route.sublist(math.min(_routeIndex + 1, _route.length - 1));
    _remaining = [cur, ...ahead];
  }

  /// Si el conductor se aleja de la ruta trazada, la recalcula desde su
  /// posición actual hacia el objetivo de la fase (origen o destino).
  Future<void> _maybeRecalcRoute() async {
    if (_refetchingRoute ||
        _phase == _NavPhase.atOrigin ||
        _current == null ||
        _route.length < 2) {
      return;
    }
    if (_offRouteMeters < 45) {
      _offRouteCount = 0;
      return;
    }
    if (++_offRouteCount < 3) return;
    final now = DateTime.now();
    if (_lastRouteFetch != null &&
        now.difference(_lastRouteFetch!).inSeconds < 8) {
      return;
    }
    _lastRouteFetch = now;
    _offRouteCount = 0;
    _refetchingRoute = true;
    final target = _phase == _NavPhase.toOrigin ? _origin : _destination;
    await _fetchRoute(_current!, target);
    _refetchingRoute = false;
  }

  Future<void> _loadRouteForPhase() async {
    final LatLng from;
    final LatLng to;
    if (_phase == _NavPhase.toOrigin) {
      from = _current ?? _origin;
      to = _origin;
    } else if (_phase == _NavPhase.atOrigin) {
      from = _origin;
      to = _destination;
    } else {
      from = _current ?? _origin;
      to = _destination;
    }
    await _fetchRoute(from, to);
  }

  Future<void> _fetchRoute(LatLng from, LatLng to) async {
    try {
      final route = await fetchDirectionsRoute(from, to);
      if (route != null && route.points.length >= 2) {
        _route = route.points;
        _routeIndex = 0;
        _remaining = _route;
        _steps = route.steps;
        _stepIndex = 0;
        _spokenStep = -1;
        _stepDistanceText = '';
        _routeDistanceMeters = route.distanceMeters;
        _routeDurationSecs = route.durationSeconds;
        _buildSuffixMeters();
        _durationText = formatDuration(route.durationSeconds);
        _distanceText = formatMeters(route.distanceMeters);
        if (mounted) setState(() {});
        if (_phase == _NavPhase.atOrigin) _fitBounds();
        return;
      }
    } catch (_) {}
    _route = [from, to];
    _routeIndex = 0;
    _remaining = _route;
    _steps = [];
    _suffixMeters = [];
    if (mounted) setState(() {});
    if (_phase == _NavPhase.atOrigin) _fitBounds();
  }

  void _buildSuffixMeters() {
    _suffixMeters = List.filled(_route.length, 0);
    for (int i = _route.length - 2; i >= 0; i--) {
      _suffixMeters[i] = _suffixMeters[i + 1] +
          Geolocator.distanceBetween(_route[i].latitude, _route[i].longitude,
              _route[i + 1].latitude, _route[i + 1].longitude);
    }
  }

  /// Recalcula el "X min · X km restantes" con cada fix del GPS.
  void _updateRemainingEta() {
    if (_current == null ||
        _route.length < 2 ||
        _suffixMeters.length != _route.length) {
      return;
    }
    final j = math.min(_routeIndex + 1, _route.length - 1);
    final meters = _suffixMeters[j] +
        Geolocator.distanceBetween(_current!.latitude, _current!.longitude,
            _route[j].latitude, _route[j].longitude);
    _distanceText = formatMeters(meters);
    if (_routeDistanceMeters > 0 && _routeDurationSecs > 0) {
      final frac = (meters / _routeDistanceMeters).clamp(0.0, 1.0);
      _durationText = formatDuration(_routeDurationSecs * frac);
    }
  }

  void _updateStep() {
    if (_steps.isEmpty || _current == null || _phase == _NavPhase.atOrigin) {
      return;
    }
    while (_stepIndex < _steps.length - 1) {
      final d = Geolocator.distanceBetween(
          _current!.latitude,
          _current!.longitude,
          _steps[_stepIndex].end.latitude,
          _steps[_stepIndex].end.longitude);
      if (d < 25) {
        _stepIndex++;
      } else {
        break;
      }
    }
    final m = Geolocator.distanceBetween(
        _current!.latitude,
        _current!.longitude,
        _steps[_stepIndex].end.latitude,
        _steps[_stepIndex].end.longitude);
    _stepDistanceText = _fmtMeters(m);

    if (_spokenStep != _stepIndex) {
      _spokenStep = _stepIndex;
      _speak(_steps[_stepIndex].instruction);
    }
  }

  String _fmtMeters(double m) => formatMeters(m);

  void _onMapCreated(GoogleMapController c) {
    _mapCtrl = c;
    if (_phase == _NavPhase.atOrigin || _current == null) {
      _fitBounds();
    } else {
      _guardedAnimate(CameraUpdate.newCameraPosition(CameraPosition(
          target: _current!, zoom: 18.5, tilt: 55, bearing: _bearing)));
    }
  }

  void _fitBounds() {
    final pts = _route.isNotEmpty ? _route : [_origin, _destination];
    Future.delayed(const Duration(milliseconds: 300),
        () => _guardedAnimate(CameraUpdate.newLatLngBounds(_bounds(pts), 70)));
  }

  Future<void> _recenter() async {
    setState(() => _follow = true);
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null && mounted) {
        _current = LatLng(pos.latitude, pos.longitude);
        if (pos.heading >= 0 && pos.heading <= 360) {
          _travelBearing = pos.heading;
        }
      }
    } catch (_) {}
    if (!mounted) return;
    final t =
        _current ?? (_phase == _NavPhase.toOrigin ? _origin : _destination);
    _guardedAnimate(CameraUpdate.newCameraPosition(
        CameraPosition(target: t, zoom: 18.5, tilt: 55, bearing: _bearing)));
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    if (_muted) _tts.stop();
  }

  /// Diferencia angular más corta entre dos rumbos, en el rango [-180, 180].
  double _shortestDelta(double from, double to) =>
      ((to - from + 540) % 360) - 180;

  void _startCompass() {
    _compassSub = FlutterCompass.events?.listen((e) {
      if (!mounted || e.heading == null) return;
      final h = (e.heading! + 360) % 360;
      final delta = _shortestDelta(_bearing, h);
      if (delta.abs() < 1) return;
      // Suavizado para que el mapa gire fluido y no a saltos con el teléfono.
      _bearing = (_bearing + delta * 0.35 + 360) % 360;
      if (_follow && _current != null && _phase != _NavPhase.atOrigin) {
        _throttledCameraRotate();
      }
      if (mounted) setState(() {}); // reevalúa el sprite del carro
    });
  }

  void _throttledCameraRotate() {
    final now = DateTime.now();
    if (_lastBearingUpdate != null &&
        now.difference(_lastBearingUpdate!).inMilliseconds < 120) {
      return;
    }
    _lastBearingUpdate = now;
    _guardedAnimate(CameraUpdate.newCameraPosition(CameraPosition(
        target: _current!, zoom: 18.5, tilt: 55, bearing: _bearing)));
  }

  Future<void> _arrivedAtOrigin() async {
    setState(() {
      _phase = _NavPhase.atOrigin;
      _follow = false;
    });
    // Notifica al cliente que el conductor ya está en el origen (status 7);
    // si el backend aún no soporta el estado, la fase local sigue igual.
    widget.provider.updateStatus(RideStatus.atOrigin);
    await _loadRouteForPhase();
    _fitBounds();
  }

  Future<void> _startToDestination() async {
    setState(() {
      _phase = _NavPhase.toDestination;
      _follow = true;
    });
    await widget.provider.updateStatus(3);
    await _loadRouteForPhase();
    if (_current != null) {
      _guardedAnimate(CameraUpdate.newCameraPosition(CameraPosition(
          target: _current!, zoom: 18.5, tilt: 55, bearing: _bearing)));
    } else {
      _fitBounds();
    }
  }

  Future<void> _arrivedAtDestination() async {
    var ok = await widget.provider.updateStatus(5);
    for (var i = 0; i < 2 && !ok; i++) {
      await Future.delayed(const Duration(seconds: 1));
      ok = await widget.provider.updateStatus(5);
    }
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'No se pudo finalizar el viaje. Revisa tu conexión e inténtalo de nuevo.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final trip = widget.provider.trip!;
    Navigator.pushReplacementNamed(context, '/payment', arguments: {
      'tripId': trip.id,
      'proposalPrice': widget.provider.proposalPrice,
      'paymentMethod': trip.paymentMethod ?? 1,
      'origin': trip.origin,
      'destination': trip.destination,
      'duration': _durationText ?? _estimatedDuration(trip.distanceKm ?? 0),
    });
  }

  String _estimatedDuration(double distKm) {
    final mins = (distKm / 70 * 60).round();
    final hrs = mins ~/ 60;
    final rem = mins % 60;
    return hrs > 0
        ? '$hrs hrs ${rem > 0 ? '$rem min' : ''}'.trim()
        : '$rem min';
  }

  LatLngBounds _bounds(List<LatLng> pts) {
    double minLat = pts.first.latitude, maxLat = pts.first.latitude;
    double minLng = pts.first.longitude, maxLng = pts.first.longitude;
    for (final p in pts) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    const double tolerance = 50;
    double? distance;
    bool sliderEnabled;
    switch (_phase) {
      case _NavPhase.toOrigin:
        distance = _distanceToTarget(_origin);
        sliderEnabled = distance != null && distance <= tolerance;
        break;
      case _NavPhase.atOrigin:
        sliderEnabled = true;
        break;
      case _NavPhase.toDestination:
        distance = _distanceToTarget(_destination);
        sliderEnabled = distance != null && distance <= tolerance;
        break;
    }

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('origin'),
        position: _origin,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Origen'),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: _destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Destino'),
      ),
      if (_current != null && _carIcon != null)
        Marker(
          markerId: const MarkerId('me'),
          position: _current!,
          icon: _carIcon!,
          rotation: _travelBearing,
          anchor: const Offset(0.5, 0.5),
          consumeTapEvents: true,
        ),
    };

    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _current ?? _origin, zoom: 18.5),
            onMapCreated: _onMapCreated,
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            buildingsEnabled: true,
            markers: markers,
            polylines: _remaining.length >= 2
                ? {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: _remaining,
                      color: cs.primary,
                      width: 6,
                      startCap: Cap.roundCap,
                      endCap: Cap.roundCap,
                      jointType: JointType.round,
                    ),
                  }
                : {},
            onCameraMoveStarted: () {
              if (_animCount == 0 && _follow) setState(() => _follow = false);
            },
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: (_phase != _NavPhase.atOrigin && _steps.isNotEmpty)
                  ? TurnBanner(
                      step: _steps[_stepIndex],
                      distanceText: _stepDistanceText,
                      colorScheme: cs)
                  : _StatusChip(phase: _phase, colorScheme: cs),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: MediaQuery.paddingOf(context).bottom + 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Speedometer(kmh: _speedKmh, colorScheme: cs),
              const Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NavButton(
                    icon: _muted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    active: !_muted,
                    onTap: _toggleMute,
                    colorScheme: cs,
                  ),
                  const SizedBox(height: 12),
                  _NavButton(
                    icon: Icons.navigation_rounded,
                    active: _follow,
                    onTap: _recenter,
                    colorScheme: cs,
                  ),
                ],
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _BottomCard(
            phase: _phase,
            colorScheme: cs,
            enabled: sliderEnabled,
            distanceMeters: distance,
            clientName: widget.provider.personName,
            clientImageUrl: widget.provider.personImageUrl,
            originLabel: widget.provider.trip!.origin,
            destinationLabel: widget.provider.trip!.destination,
            paymentMethod: widget.provider.trip!.paymentMethod,
            durationText: _durationText,
            distanceText: _distanceText,
            onArrivedOrigin: _arrivedAtOrigin,
            onStartToDestination: _startToDestination,
            onArrivedDestination: _arrivedAtDestination,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final _NavPhase phase;
  final ColorScheme colorScheme;
  const _StatusChip({required this.phase, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final label = switch (phase) {
      _NavPhase.toOrigin => 'En ruta al origen',
      _NavPhase.atOrigin => 'En el origen',
      _NavPhase.toDestination => 'En ruta al destino',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: colorScheme.primary, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

class _Speedometer extends StatelessWidget {
  final double kmh;
  final ColorScheme colorScheme;
  const _Speedometer({required this.kmh, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(kmh <= 0.5 ? '--' : kmh.round().toString(),
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  height: 1)),
          Text('km/h',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 9)),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool active;
  const _NavButton(
      {required this.icon,
      required this.onTap,
      required this.colorScheme,
      this.active = false});

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Material(
      color: cs.surfaceContainerLowest,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon,
              color: active ? cs.primary : cs.onSurfaceVariant, size: 24),
        ),
      ),
    );
  }
}

class _BottomCard extends StatefulWidget {
  final _NavPhase phase;
  final ColorScheme colorScheme;
  final bool enabled;
  final double? distanceMeters;
  final String clientName;
  final String? clientImageUrl;
  final String originLabel;
  final String destinationLabel;
  final int? paymentMethod;
  final String? durationText;
  final String? distanceText;
  final VoidCallback onArrivedOrigin;
  final VoidCallback onStartToDestination;
  final VoidCallback onArrivedDestination;

  const _BottomCard({
    required this.phase,
    required this.colorScheme,
    required this.enabled,
    required this.distanceMeters,
    required this.clientName,
    required this.clientImageUrl,
    required this.originLabel,
    required this.destinationLabel,
    required this.paymentMethod,
    required this.durationText,
    required this.distanceText,
    required this.onArrivedOrigin,
    required this.onStartToDestination,
    required this.onArrivedDestination,
  });

  @override
  State<_BottomCard> createState() => _BottomCardState();
}

class _BottomCardState extends State<_BottomCard> {
  bool _expanded = false;

  void _set(bool v) {
    if (_expanded != v) setState(() => _expanded = v);
  }

  String _short(String s) => s.split(',').first.trim();
  String _fmt(double m) =>
      m >= 1000 ? '${(m / 1000).toStringAsFixed(1)} km' : '${m.round()} m';

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final (label, action) = switch (widget.phase) {
      _NavPhase.toOrigin => (
          'Desliza al llegar al origen',
          widget.onArrivedOrigin
        ),
      _NavPhase.atOrigin => (
          'Desliza para iniciar ruta al destino',
          widget.onStartToDestination
        ),
      _NavPhase.toDestination => (
          'Desliza al llegar al destino',
          widget.onArrivedDestination
        ),
    };
    final targetName =
        widget.phase == _NavPhase.toOrigin ? 'origen' : 'destino';
    final eta = [
      if (widget.durationText != null) widget.durationText!,
      if (widget.distanceText != null) widget.distanceText!,
    ].join(' · ');

    return Material(
      color: cs.surfaceContainerLowest,
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: SafeArea(
        top: false,
        // Alto limitado + contenido con scroll para que el panel nunca se
        // desborde; el slider de confirmación queda siempre visible abajo.
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _set(!_expanded),
                onVerticalDragEnd: (d) {
                  final v = d.primaryVelocity ?? 0;
                  if (v > 0) {
                    _set(false);
                  } else if (v < 0) {
                    _set(true);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 2),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: cs.outlineVariant,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      if (eta.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule_outlined,
                                  size: 14, color: cs.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text('$eta restantes',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: cs.onSurfaceVariant,
                                          fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              Icon(
                                  _expanded
                                      ? Icons.keyboard_arrow_down_rounded
                                      : Icons.keyboard_arrow_up_rounded,
                                  size: 18,
                                  color: cs.onSurfaceVariant),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: _expanded
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.clientName.isNotEmpty)
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: cs.primaryContainer,
                                        backgroundImage:
                                            (widget.clientImageUrl != null &&
                                                    widget.clientImageUrl!
                                                        .isNotEmpty)
                                                ? CachedNetworkImageProvider(
                                                    widget.clientImageUrl!)
                                                : null,
                                        child: (widget.clientImageUrl == null ||
                                                widget.clientImageUrl!.isEmpty)
                                            ? Text(
                                                widget.clientName[0]
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    color: cs.primary,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Cliente',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                        color: cs
                                                            .onSurfaceVariant)),
                                            Text(widget.clientName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                _RouteRow(
                                    color: cs.primary,
                                    title: 'Origen',
                                    label: _short(widget.originLabel),
                                    cs: cs),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Container(
                                      width: 2,
                                      height: 14,
                                      color: cs.outlineVariant),
                                ),
                                _RouteRow(
                                    color: Colors.red,
                                    title: 'Destino',
                                    label: _short(widget.destinationLabel),
                                    cs: cs),
                                const SizedBox(height: 12),
                                Row(children: [
                                  Icon(
                                      PaymentMethodInfo.icon(
                                          widget.paymentMethod),
                                      size: 16,
                                      color: cs.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Método de pago: ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                  Text(
                                    PaymentMethodInfo.label(
                                        widget.paymentMethod),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: cs.onSurface,
                                            fontWeight: FontWeight.w600),
                                  ),
                                ]),
                              ],
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!widget.enabled) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.my_location,
                              size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.distanceMeters == null
                                  ? 'Obteniendo tu ubicación…'
                                  : 'Acércate al $targetName · a ${_fmt(widget.distanceMeters!)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    SlideToConfirm(
                      key: ValueKey(widget.phase),
                      label: label,
                      enabled: widget.enabled,
                      background: cs.primary,
                      foreground: cs.onPrimary,
                      onConfirmed: action,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final Color color;
  final String title;
  final String label;
  final ColorScheme cs;
  const _RouteRow(
      {required this.color,
      required this.title,
      required this.label,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
