import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/payment_method.dart';
import '../../../../core/utils/ride_status.dart';
import '../../proposals/proposal_enrichment.dart';
import '../../../../core/config/api_keys.dart';

const _mapsKey = googleMapsApiKey;

class HistoryTripDetailScreen extends StatefulWidget {
  final Trip trip;
  final Proposal? proposal;
  const HistoryTripDetailScreen({super.key, required this.trip, this.proposal});

  @override
  State<HistoryTripDetailScreen> createState() =>
      _HistoryTripDetailScreenState();
}

class _HistoryTripDetailScreenState extends State<HistoryTripDetailScreen> {
  late Trip _trip = widget.trip;
  Proposal? _proposal;
  bool _loading = true;
  List<LatLng> _route = [];
  GoogleMapController? _mapCtrl;

  bool get _isCompleted => _trip.status == RideStatus.completed;

  bool get _hasCoords =>
      !(_trip.originLat == 0 && _trip.originLng == 0) &&
      !(_trip.destinationLat == 0 && _trip.destinationLng == 0);

  bool get _showMap => _isCompleted && _hasCoords;

  @override
  void initState() {
    super.initState();
    _proposal = widget.proposal;
    _load();
  }

  @override
  void dispose() {
    _mapCtrl?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await context.read<ApiService>().getRideById(widget.trip.id);
      final data = res.data['ride'] ?? res.data;
      _trip = Trip.fromJson(data as Map<String, dynamic>);
    } catch (_) {}

    if (_proposal == null) {
      try {
        _proposal = await fetchAcceptedProposal(widget.trip.id);
      } catch (_) {}
    }

    if (mounted) setState(() => _loading = false);
    if (_showMap) await _loadRoute();
  }

  Future<void> _loadRoute() async {
    try {
      final res = await Dio().get(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${_trip.originLat},${_trip.originLng}'
        '&destination=${_trip.destinationLat},${_trip.destinationLng}'
        '&mode=driving&language=es&key=$_mapsKey',
      );
      final routes = res.data['routes'] as List? ?? [];
      if (routes.isNotEmpty) {
        final encoded = routes[0]['overview_polyline']?['points'] as String?;
        if (encoded != null) _route = _decodePolyline(encoded);
      }
    } catch (_) {}

    if (_route.isEmpty) {
      _route = [
        LatLng(_trip.originLat, _trip.originLng),
        LatLng(_trip.destinationLat, _trip.destinationLng),
      ];
    }
    if (mounted) {
      setState(() {});
      _fitBounds();
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLat = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lat += dLat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLng = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lng += dLng;
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  void _fitBounds() {
    if (_mapCtrl == null) return;
    final pts = [
      LatLng(_trip.originLat, _trip.originLng),
      LatLng(_trip.destinationLat, _trip.destinationLng),
      ..._route,
    ];
    double minLat = pts.first.latitude, maxLat = pts.first.latitude;
    double minLng = pts.first.longitude, maxLng = pts.first.longitude;
    for (final p in pts) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    _mapCtrl!.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      ),
      48,
    ));
  }

  static const _months = [
    '',
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  String _formatDate(String raw) {
    try {
      final datePart = raw.split('T').first;
      final parts = datePart.split('-');
      if (parts.length < 3) return raw;
      final day = int.parse(parts[2]);
      final month = int.parse(parts[1]);
      return '$day de ${_months[month]} de ${parts[0]}';
    } catch (_) {
      return raw;
    }
  }

  String _formatHour(String raw) {
    try {
      final timePart = raw.contains('T') ? raw.split('T').last : raw;
      final cleaned = timePart.replaceAll('Z', '');
      final parts = cleaned.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')} hrs';
      }
      return raw;
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detalle del viaje',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_showMap)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 240,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_trip.originLat, _trip.originLng),
                          zoom: 12,
                        ),
                        onMapCreated: (ctrl) {
                          _mapCtrl = ctrl;
                          _fitBounds();
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId('origin'),
                            position: LatLng(_trip.originLat, _trip.originLng),
                            infoWindow: InfoWindow(
                                title: 'Origen', snippet: _trip.origin),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen),
                          ),
                          Marker(
                            markerId: const MarkerId('destination'),
                            position: LatLng(
                                _trip.destinationLat, _trip.destinationLng),
                            infoWindow: InfoWindow(
                                title: 'Destino', snippet: _trip.destination),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed),
                          ),
                        },
                        polylines: {
                          if (_route.isNotEmpty)
                            Polyline(
                              polylineId: const PolylineId('route'),
                              points: _route,
                              color: colorScheme.primary,
                              width: 5,
                            ),
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.map_outlined,
                            color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _isCompleted
                                ? 'La ruta de este viaje no está disponible'
                                : 'La ruta no está disponible para viajes cancelados',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                _StatusChip(
                    status: _trip.status,
                    cancelReason: _trip.cancelReason,
                    colorScheme: colorScheme,
                    date: _trip.createdAt),
                const SizedBox(height: 12),
                _Card(
                  colorScheme: colorScheme,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                          icon: Icons.route_outlined,
                          label: 'Recorrido',
                          colorScheme: colorScheme),
                      const SizedBox(height: 14),
                      _RoutePoint(
                        icon: Icons.location_on,
                        iconColor: Colors.green,
                        label: 'Origen',
                        value: _trip.origin,
                        colorScheme: colorScheme,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 11),
                        child: Container(
                          width: 2,
                          height: 18,
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      _RoutePoint(
                        icon: Icons.flag,
                        iconColor: colorScheme.error,
                        label: 'Destino',
                        value: _trip.destination,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ),
                if (_proposal?.driver != null) ...[
                  const SizedBox(height: 12),
                  _DriverCard(proposal: _proposal!, colorScheme: colorScheme),
                ],
                const SizedBox(height: 12),
                _Card(
                  colorScheme: colorScheme,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                          icon: Icons.info_outline,
                          label: 'Información del viaje',
                          colorScheme: colorScheme),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Fecha', value: _formatDate(_trip.date)),
                      _InfoRow(label: 'Hora', value: _formatHour(_trip.hour)),
                      _InfoRow(
                          label: 'Peso aprox.',
                          value: '${_trip.approxWeight.toInt()} kg'),
                      if (_trip.distanceKm != null)
                        _InfoRow(
                            label: 'Distancia',
                            value:
                                '${_trip.distanceKm!.toStringAsFixed(1)} km'),
                      _InfoRow(
                          label: 'Método de pago',
                          value: PaymentMethodInfo.label(_trip.paymentMethod)),
                      if (_proposal != null)
                        _InfoRow(
                            label: 'Costo',
                            value: Money.mxn(_proposal!.price),
                            highlight: true,
                            isLast: _trip.description == null ||
                                _trip.description!.isEmpty),
                      if (_trip.description != null &&
                          _trip.description!.isNotEmpty)
                        _InfoRow(
                            label: 'Descripción',
                            value: _trip.description!,
                            isLast: true),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final int status;
  final int? cancelReason;
  final ColorScheme colorScheme;
  final String? date;
  const _StatusChip(
      {required this.status,
      this.cancelReason,
      required this.colorScheme,
      this.date});

  @override
  Widget build(BuildContext context) {
    final cancelled = status == RideStatus.cancelled;
    final label = cancelled && cancelReason == CancelReason.expired
        ? 'Expiró'
        : RideStatus.label(status);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: cancelled
                ? colorScheme.errorContainer
                : colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                cancelled ? Icons.cancel_outlined : Icons.check_circle_outline,
                size: 15,
                color: cancelled ? colorScheme.error : colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: cancelled ? colorScheme.error : colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DriverCard extends StatelessWidget {
  final Proposal proposal;
  final ColorScheme colorScheme;
  const _DriverCard({required this.proposal, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final driver = proposal.driver!;
    final driverName = '${driver.name} ${driver.lastname}'.trim();
    final initial = driverName.isNotEmpty ? driverName[0].toUpperCase() : 'C';

    return _Card(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
              icon: Icons.person_outline,
              label: 'Chofer',
              colorScheme: colorScheme),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage:
                    (driver.imageUrl != null && driver.imageUrl!.isNotEmpty)
                        ? CachedNetworkImageProvider(driver.imageUrl!)
                            as ImageProvider
                        : null,
                child: (driver.imageUrl == null || driver.imageUrl!.isEmpty)
                    ? Text(
                        initial,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName.isNotEmpty ? driverName : 'Conductor',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (driver.rating != null)
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFFFFC107)),
                        const SizedBox(width: 2),
                        Text(
                          driver.rating!.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ]),
                  ],
                ),
              ),
              Text(
                Money.mxn(proposal.price),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final ColorScheme colorScheme;
  const _RoutePoint({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      )),
              Text(value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final ColorScheme colorScheme;
  const _Card({required this.child, required this.colorScheme});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  const _SectionTitle(
      {required this.icon, required this.label, required this.colorScheme});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
        ],
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  final bool highlight;
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      )),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            highlight ? FontWeight.bold : FontWeight.w600,
                        color: highlight ? colorScheme.primary : null,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: colorScheme.outlineVariant),
      ],
    );
  }
}
