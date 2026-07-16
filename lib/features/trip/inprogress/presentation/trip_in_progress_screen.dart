import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/car_marker.dart';
import '../../../../core/utils/directions.dart';
import '../../../../core/utils/payment_method.dart';
import '../../../../core/utils/ride_status.dart';
import '../../../../core/websocket/websocket_manager.dart';
import '../../../../core/widgets/turn_banner.dart';
import '../../../main/widgets/driver_app_bar.dart';
import '../../payment/presentation/cash_payment_wait_screen.dart';
import '../../payment/presentation/client_payment_screen.dart';
import '../../proposals/proposal_enrichment.dart';

class TripInProgressScreen extends StatefulWidget {
  final Trip trip;
  const TripInProgressScreen({super.key, required this.trip});

  @override
  State<TripInProgressScreen> createState() => _TripInProgressScreenState();
}

class _TripInProgressScreenState extends State<TripInProgressScreen> {
  GoogleMapController? _mapCtrl;
  Proposal? _acceptedProposal;
  List<LatLng> _polylinePoints = [];
  List<LatLng> _remaining = [];
  int _routeIndex = 0;
  String? _duration;

  final WebSocketManager _ws = WebSocketManager();
  LatLng? _driverLatLng;
  double _driverBearing = 0;
  bool _follow = true;
  int _animCount = 0;
  BitmapDescriptor? _carIcon;

  late int _rideStatus = widget.trip.status;
  Timer? _statusTimer;
  double _offRouteMeters = 0;
  int _offRouteCount = 0;
  DateTime? _lastRouteFetch;
  bool _refetchingRoute = false;
  bool _wentToPayment = false;

  // Pasos de la ruta para el banner de instrucciones (se avanzan con la
  // posición del conductor que llega por WebSocket, sin narrador de voz).
  List<NavStep> _steps = [];
  int _stepIndex = 0;
  String _stepDistanceText = '';

  /// [_suffixMeters]\[i\] = metros desde _polylinePoints[i] hasta el final;
  /// permite recalcular en vivo el tiempo/distancia restantes.
  List<double> _suffixMeters = [];
  double _routeDistanceMeters = 0;
  double _routeDurationSecs = 0;

  /// Cámara de navegación (siguiendo al carrito) solo cuando el viaje ya va
  /// del origen al destino; mientras el conductor va al origen, vista plana.
  bool get _navMode => _rideStatus == RideStatus.inProcess;

  LatLng get _originLatLng =>
      LatLng(widget.trip.originLat, widget.trip.originLng);
  LatLng get _destinationLatLng =>
      LatLng(widget.trip.destinationLat, widget.trip.destinationLng);

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscribeDriverLocation();
    _buildCarIcon();
    _statusTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => _refreshStatus());
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _ws.disconnect();
    _mapCtrl?.dispose();
    super.dispose();
  }

  Future<void> _buildCarIcon() async {
    final icon = await buildCarMarker();
    if (!mounted) return;
    setState(() => _carIcon = icon);
  }

  Future<void> _subscribeDriverLocation() async {
    final token = await sl.tokenManager.getToken();
    if (token == null || token.isEmpty) return;
    _ws.onMessage = (msg) {
      try {
        final data = jsonDecode(msg) as Map<String, dynamic>;
        final lat = (data['lat'] ?? data['latitude']) as num?;
        final lng = (data['lng'] ?? data['longitude']) as num?;
        if (lat == null || lng == null || !mounted) return;
        final pos = LatLng(lat.toDouble(), lng.toDouble());
        final bearing = (data['bearing'] ?? data['heading']) as num?;
        final firstFix = _driverLatLng == null;
        setState(() {
          _driverLatLng = pos;
          if (bearing != null) _driverBearing = bearing.toDouble();
          _trimTraveledRoute();
          _updateStepFromDriver();
          _updateRemainingEta();
        });
        if (_navMode && _follow) {
          // Misma cámara de navegación que la vista del conductor: gira con
          // el rumbo que él lleva, no con los sensores del teléfono cliente.
          _guardedAnimate(CameraUpdate.newCameraPosition(CameraPosition(
              target: pos, zoom: 18.5, tilt: 55, bearing: _driverBearing)));
        }
        if (firstFix && !_navMode) {
          // Conductor rumbo al origen: se dibuja su ruta hacia el origen.
          _loadRoute(pos, _originLatLng, fit: true);
        } else {
          _maybeRecalcRoute();
        }
      } catch (_) {}
    };
    _ws.connect(
      'wss://api-logired.shop/ws/rides/${widget.trip.id}/subscribe?token=$token',
    );
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadAcceptedProposal(),
      // Yendo al origen la ruta se traza desde la posición del conductor
      // cuando llega su primer fix por WebSocket.
      if (_navMode) _loadRoute(_originLatLng, _destinationLatLng, fit: true),
    ]);
  }

  Future<void> _loadAcceptedProposal() async {
    try {
      final response = await sl.apiService.getProposalsByRide(widget.trip.id);
      final list = (response.data['proposals'] as List? ?? [])
          .map((e) => Proposal.fromJson(e))
          .toList();
      final basic = list.where((p) => p.status == 1).firstOrNull;
      if (basic == null) return;
      final full = await enrichProposal(basic);
      if (mounted) setState(() => _acceptedProposal = full);
    } catch (_) {}
  }

  Future<void> _loadRoute(LatLng from, LatLng to, {bool fit = false}) async {
    if (from.latitude == 0 && from.longitude == 0) return;
    try {
      final route = await fetchDirectionsRoute(from, to);
      if (route == null || route.points.length < 2) return;
      _polylinePoints = route.points;
      _routeIndex = 0;
      _steps = route.steps;
      _stepIndex = 0;
      _stepDistanceText = '';
      _routeDistanceMeters = route.distanceMeters;
      _routeDurationSecs = route.durationSeconds;
      _buildSuffixMeters();
      _duration = formatDuration(route.durationSeconds);
      _trimTraveledRoute();
      _updateStepFromDriver();
      if (mounted) {
        setState(() {});
        if (fit) _fitBounds();
      }
    } catch (_) {}
  }

  void _buildSuffixMeters() {
    _suffixMeters = List.filled(_polylinePoints.length, 0);
    for (int i = _polylinePoints.length - 2; i >= 0; i--) {
      _suffixMeters[i] = _suffixMeters[i + 1] +
          Geolocator.distanceBetween(
              _polylinePoints[i].latitude,
              _polylinePoints[i].longitude,
              _polylinePoints[i + 1].latitude,
              _polylinePoints[i + 1].longitude);
    }
  }

  /// Recalcula el tiempo restante mostrado con cada posición del conductor.
  void _updateRemainingEta() {
    if (_driverLatLng == null ||
        _polylinePoints.length < 2 ||
        _suffixMeters.length != _polylinePoints.length) {
      return;
    }
    final j = math.min(_routeIndex + 1, _polylinePoints.length - 1);
    final meters = _suffixMeters[j] +
        Geolocator.distanceBetween(
            _driverLatLng!.latitude,
            _driverLatLng!.longitude,
            _polylinePoints[j].latitude,
            _polylinePoints[j].longitude);
    if (_routeDistanceMeters > 0 && _routeDurationSecs > 0) {
      final frac = (meters / _routeDistanceMeters).clamp(0.0, 1.0);
      _duration = formatDuration(_routeDurationSecs * frac);
    }
  }

  /// Avanza el paso de navegación del banner según la posición del conductor.
  void _updateStepFromDriver() {
    if (_steps.isEmpty || _driverLatLng == null) return;
    while (_stepIndex < _steps.length - 1) {
      final d = Geolocator.distanceBetween(
          _driverLatLng!.latitude,
          _driverLatLng!.longitude,
          _steps[_stepIndex].end.latitude,
          _steps[_stepIndex].end.longitude);
      if (d < 25) {
        _stepIndex++;
      } else {
        break;
      }
    }
    final m = Geolocator.distanceBetween(
        _driverLatLng!.latitude,
        _driverLatLng!.longitude,
        _steps[_stepIndex].end.latitude,
        _steps[_stepIndex].end.longitude);
    _stepDistanceText = formatMeters(m);
  }

  /// Si el conductor se aleja de la ruta dibujada, se recalcula desde su
  /// posición actual (hacia el origen o el destino según la fase).
  Future<void> _maybeRecalcRoute() async {
    if (_refetchingRoute ||
        _driverLatLng == null ||
        _polylinePoints.length < 2) {
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
    await _loadRoute(
        _driverLatLng!, _navMode ? _destinationLatLng : _originLatLng);
    _refetchingRoute = false;
  }

  Future<void> _refreshStatus() async {
    try {
      final r = await sl.apiService.getRideById(widget.trip.id);
      final rd = (r.data['ride'] ?? r.data) as Map<String, dynamic>;
      final s = (rd['idstatus'] ?? rd['status']) as int?;
      if (s == null || s == _rideStatus || !mounted) return;
      setState(() => _rideStatus = s);
      if (s == RideStatus.completed) {
        // Viaje terminado: pasa al flujo de pago (tarjeta o efectivo).
        _goToPaymentFlow();
        return;
      }
      if (_navMode) {
        // Arrancó la ruta al destino: nueva ruta y cámara de navegación.
        await _loadRoute(_driverLatLng ?? _originLatLng, _destinationLatLng);
        if (_driverLatLng != null && _follow) {
          _guardedAnimate(CameraUpdate.newCameraPosition(CameraPosition(
              target: _driverLatLng!,
              zoom: 18.5,
              tilt: 55,
              bearing: _driverBearing)));
        }
      }
    } catch (_) {}
  }

  Future<void> _goToPaymentFlow() async {
    if (_wentToPayment) return;
    _wentToPayment = true;
    _statusTimer?.cancel();
    if (_acceptedProposal == null) await _loadAcceptedProposal();
    if (!mounted) return;
    final proposal = _acceptedProposal;
    if (proposal == null) {
      _wentToPayment = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('El viaje terminó, pero no se pudo cargar el monto a '
            'pagar. Revisa tu conexión.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final isCard = PaymentMethodInfo.isCard(widget.trip.paymentMethod);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => isCard
          ? ClientPaymentScreen(
              trip: widget.trip, proposal: proposal, duration: _duration)
          : CashPaymentWaitScreen(
              trip: widget.trip, proposal: proposal, duration: _duration),
    ));
  }

  void _guardedAnimate(CameraUpdate u) {
    _animCount++;
    _mapCtrl?.animateCamera(u).whenComplete(() {
      if (mounted && _animCount > 0) _animCount--;
    });
  }

  /// Recorta la parte ya recorrida de la ruta para dibujar solo lo que falta
  /// desde la posición del conductor (misma lógica que la vista del conductor).
  void _trimTraveledRoute() {
    if (_driverLatLng == null || _polylinePoints.length < 2) {
      _remaining = _polylinePoints;
      return;
    }
    final cur = _driverLatLng!;
    int best = _routeIndex;
    double bestDist = double.infinity;
    final end = math.min(_polylinePoints.length - 1, _routeIndex + 40);
    for (int i = _routeIndex; i <= end; i++) {
      final d = Geolocator.distanceBetween(cur.latitude, cur.longitude,
          _polylinePoints[i].latitude, _polylinePoints[i].longitude);
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    _routeIndex = best;
    _offRouteMeters = bestDist.isFinite ? bestDist : 0;
    final ahead = _polylinePoints
        .sublist(math.min(_routeIndex + 1, _polylinePoints.length - 1));
    _remaining = [cur, ...ahead];
  }

  LatLngBounds _polylineBounds() {
    double minLat = _polylinePoints.first.latitude,
        maxLat = _polylinePoints.first.latitude;
    double minLng = _polylinePoints.first.longitude,
        maxLng = _polylinePoints.first.longitude;
    for (final p in _polylinePoints) {
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

  void _fitBounds() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_mapCtrl == null) return;
      if (_polylinePoints.isNotEmpty) {
        _mapCtrl!
            .animateCamera(CameraUpdate.newLatLngBounds(_polylineBounds(), 64));
      } else {
        final trip = widget.trip;
        _mapCtrl!.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              math.min(trip.originLat, trip.destinationLat),
              math.min(trip.originLng, trip.destinationLng),
            ),
            northeast: LatLng(
              math.max(trip.originLat, trip.destinationLat),
              math.max(trip.originLng, trip.destinationLng),
            ),
          ),
          64,
        ));
      }
    });
  }

  void _centerMap() {
    setState(() => _follow = true);
    if (_navMode && _driverLatLng != null) {
      _guardedAnimate(CameraUpdate.newCameraPosition(CameraPosition(
          target: _driverLatLng!,
          zoom: 18.5,
          tilt: 55,
          bearing: _driverBearing)));
    } else {
      _fitBounds();
    }
  }

  String _shortPlace(String full) => full.split(',').first.trim();

  Future<void> _call(UserResponse? driver) async {
    final phone = driver?.numberPhone.replaceAll(RegExp(r'\s+'), '') ?? '';
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final trip = widget.trip;
    final origin = LatLng(trip.originLat, trip.originLng);
    final destination = LatLng(trip.destinationLat, trip.destinationLng);
    final midpoint = LatLng(
      (trip.originLat + trip.destinationLat) / 2,
      (trip.originLng + trip.destinationLng) / 2,
    );

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: const DriverAppBar(showBack: true),
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: midpoint, zoom: 8),
              onMapCreated: (c) {
                _mapCtrl = c;
                _fitBounds();
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('origin'),
                  position: origin,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                  infoWindow: const InfoWindow(title: 'Origen'),
                ),
                Marker(
                  markerId: const MarkerId('destination'),
                  position: destination,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                  infoWindow: const InfoWindow(title: 'Destino'),
                ),
                if (_driverLatLng != null && _carIcon != null)
                  Marker(
                    markerId: const MarkerId('driver'),
                    position: _driverLatLng!,
                    icon: _carIcon!,
                    // La rotación es absoluta (rumbo real); en modo navegación
                    // la cámara gira con el mismo rumbo (heading-up) y el carro
                    // se ve siempre "de frente"; en vista plana (norte-arriba)
                    // se ve girado según su rumbo real.
                    rotation: _driverBearing,
                    infoWindow: const InfoWindow(title: 'Conductor'),
                    anchor: const Offset(0.5, 0.5),
                  ),
              },
              polylines: () {
                final pts = _driverLatLng != null && _remaining.length >= 2
                    ? _remaining
                    : _polylinePoints;
                return pts.length >= 2
                    ? {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: pts,
                          color: cs.primary,
                          width: 6,
                          startCap: Cap.roundCap,
                          endCap: Cap.roundCap,
                          jointType: JointType.round,
                        ),
                      }
                    : <Polyline>{};
              }(),
              onCameraMoveStarted: () {
                if (_navMode && _animCount == 0 && _follow) {
                  setState(() => _follow = false);
                }
              },
            ),
          ),
          // Banner de instrucciones (misma vista que el conductor, sin voz).
          if (_navMode && _steps.isNotEmpty && _driverLatLng != null)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: TurnBanner(
                      step: _steps[_stepIndex],
                      distanceText: _stepDistanceText,
                      colorScheme: cs),
                ),
              ),
            ),
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 190,
            child: FloatingActionButton.small(
              heroTag: 'centerMapBtn',
              backgroundColor: cs.surfaceContainerLowest,
              foregroundColor: cs.primary,
              elevation: 4,
              onPressed: _centerMap,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _TrackingBottomCard(
              trip: trip,
              proposal: _acceptedProposal,
              duration: _duration,
              rideStatus: _rideStatus,
              shortPlace: _shortPlace,
              onCall: () => _call(_acceptedProposal?.driver),
              colorScheme: cs,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingBottomCard extends StatefulWidget {
  final Trip trip;
  final Proposal? proposal;
  final String? duration;
  final int rideStatus;
  final String Function(String) shortPlace;
  final VoidCallback onCall;
  final ColorScheme colorScheme;

  const _TrackingBottomCard({
    required this.trip,
    required this.proposal,
    required this.duration,
    required this.rideStatus,
    required this.shortPlace,
    required this.onCall,
    required this.colorScheme,
  });

  @override
  State<_TrackingBottomCard> createState() => _TrackingBottomCardState();
}

class _TrackingBottomCardState extends State<_TrackingBottomCard> {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final trip = widget.trip;
    final driver = widget.proposal?.driver;
    final car = widget.proposal?.car;
    final driverName =
        driver != null ? '${driver.name} ${driver.lastname}'.trim() : null;

    return Material(
      color: cs.surfaceContainerLowest,
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        // El alto se limita y el contenido hace scroll: el panel nunca puede
        // desbordarse aunque la pantalla sea chica o el contenido crezca.
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggle,
                onVerticalDragEnd: (d) {
                  final v = d.primaryVelocity ?? 0;
                  if (v > 0 && _expanded) setState(() => _expanded = false);
                  if (v < 0 && !_expanded) setState(() => _expanded = true);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: cs.outlineVariant,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: cs.primary, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            switch (widget.rideStatus) {
                              RideStatus.onTheWay =>
                                'Conductor en camino al origen',
                              RideStatus.atOrigin =>
                                'El conductor está en el origen',
                              RideStatus.inProcess => 'En camino al destino',
                              _ => 'Viaje en curso',
                            },
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_up_rounded,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.rideStatus == RideStatus.atOrigin)
                              Row(children: [
                                Icon(Icons.place_outlined,
                                    size: 14, color: cs.onSurfaceVariant),
                                const SizedBox(width: 5),
                                Text(
                                  'El conductor te espera en el punto de origen',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ])
                            else if (widget.duration != null)
                              Row(children: [
                                Icon(Icons.schedule_outlined,
                                    size: 14, color: cs.onSurfaceVariant),
                                const SizedBox(width: 5),
                                Text(
                                  widget.rideStatus == RideStatus.inProcess
                                      ? 'Llegada estimada: ${widget.duration} restantes'
                                      : 'Llega al origen en ${widget.duration}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ]),
                            const SizedBox(height: 10),
                            _RouteRow(
                                color: cs.primary,
                                title: 'Origen',
                                label: widget.shortPlace(trip.origin),
                                cs: cs),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Container(
                                  width: 2,
                                  height: 12,
                                  color: cs.outlineVariant),
                            ),
                            _RouteRow(
                                color: Colors.red,
                                title: 'Destino',
                                label: widget.shortPlace(trip.destination),
                                cs: cs),
                            const SizedBox(height: 12),
                            Row(children: [
                              Icon(PaymentMethodInfo.icon(trip.paymentMethod),
                                  size: 16, color: cs.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text(
                                'Método de pago: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant),
                              ),
                              Text(
                                PaymentMethodInfo.label(trip.paymentMethod),
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
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: _expanded
                            ? Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 14, 20, 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(height: 1),
                                    const SizedBox(height: 16),
                                    if (driverName != null) ...[
                                      _SectionLabel(label: 'Conductor', cs: cs),
                                      const SizedBox(height: 12),
                                      Center(
                                        child: CircleAvatar(
                                          radius: 52,
                                          backgroundColor: cs.primaryContainer,
                                          backgroundImage: (driver?.imageUrl !=
                                                      null &&
                                                  driver!.imageUrl!.isNotEmpty)
                                              ? CachedNetworkImageProvider(
                                                  driver.imageUrl!)
                                              : null,
                                          child: (driver?.imageUrl == null ||
                                                  driver!.imageUrl!.isEmpty)
                                              ? Text(
                                                  driverName.isNotEmpty
                                                      ? driverName[0]
                                                          .toUpperCase()
                                                      : 'C',
                                                  style: TextStyle(
                                                    color: cs.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 36,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Center(
                                        child: Text(
                                          driverName,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (driver?.rating != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.star_rounded,
                                                size: 18,
                                                color: Color(0xFFFFC107)),
                                            const SizedBox(width: 4),
                                            Text(
                                              driver!.rating!
                                                  .toStringAsFixed(1),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 20),
                                    ],
                                    if (car != null) ...[
                                      _SectionLabel(label: 'Vehículo', cs: cs),
                                      const SizedBox(height: 12),
                                      _CarPhoto(
                                          imageUrl: car.frontViewImage, cs: cs),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: [
                                          _InfoTag(label: car.brand, cs: cs),
                                          _InfoTag(label: car.model, cs: cs),
                                          _InfoTag(label: car.color, cs: cs),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                    if (driverName != null) ...[
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: ElevatedButton.icon(
                                          onPressed: widget.onCall,
                                          icon:
                                              const Icon(Icons.phone_outlined),
                                          label: const Text(
                                              'Contactar conductor',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: cs.primary,
                                            foregroundColor: cs.onPrimary,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ],
                                ),
                              )
                            : const SizedBox(
                                width: double.infinity, height: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _SectionLabel({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _InfoTag({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CarPhoto extends StatelessWidget {
  final String? imageUrl;
  final ColorScheme cs;
  const _CarPhoto({required this.imageUrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => _placeholder(cs),
          errorWidget: (_, __, ___) => _placeholder(cs),
        ),
      );
    }
    return _placeholder(cs);
  }

  Widget _placeholder(ColorScheme cs) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Icon(Icons.directions_car_outlined,
          size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
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
