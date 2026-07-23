import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../domain/my_trips_repository.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/utils/payment_method.dart';
import '../../../../core/utils/ride_status.dart';
import '../../inprogress/presentation/trip_in_progress_screen.dart';
import '../../proposals/presentation/proposal_detail_screen.dart';
import '../../proposals/proposal_enrichment.dart';
import 'my_trips_provider.dart';

const int _kWaiting = 0;
const int _kAssigned = 1;
const int _kInProgress = 2;

class MyTripsScreen extends StatefulWidget {
  final bool isActive;
  const MyTripsScreen({super.key, this.isActive = true});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  late final MyTripsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = MyTripsProvider(context.read<MyTripsRepository>())..loadTrips();
  }

  @override
  void didUpdateWidget(covariant MyTripsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _provider.loadTrips();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: const _MyTripsBody(),
    );
  }
}

class _MyTripsBody extends StatefulWidget {
  const _MyTripsBody();

  @override
  State<_MyTripsBody> createState() => _MyTripsBodyState();
}

class _MyTripsBodyState extends State<_MyTripsBody> {
  int _filterMode = _kWaiting;

  static bool _isAssigned(Trip t) => t.status == RideStatus.assigned;
  static bool _isInProgress(Trip t) => RideStatus.isInCourse(t.status);

  List<Trip> _filtered(List<Trip> all) {
    switch (_filterMode) {
      case _kWaiting:
        return all
            .where((t) => t.status == RideStatus.pending && t.driverId == null)
            .toList();
      case _kAssigned:
        return all.where(_isAssigned).toList();
      case _kInProgress:
        return all.where(_isInProgress).toList();
      default:
        return [];
    }
  }

  void _selectFilter(int mode, MyTripsProvider provider) {
    setState(() => _filterMode = mode);
    provider.loadTrips();
  }

  int _countWaiting(List<Trip> all) => all
      .where((t) => t.status == RideStatus.pending && t.driverId == null)
      .length;
  int _countAssigned(List<Trip> all) => all.where(_isAssigned).length;
  int _countInProgress(List<Trip> all) => all.where(_isInProgress).length;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<MyTripsProvider>(
      builder: (context, provider, _) {
        final filtered = _filtered(provider.trips);

        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLow,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: provider.loadTrips,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mis Viajes',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gestiona tus viajes y acepta las mejores propuestas',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 14),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterChip(
                                  label: 'Activos',
                                  count: _countWaiting(provider.trips),
                                  selected: _filterMode == _kWaiting,
                                  onTap: () =>
                                      _selectFilter(_kWaiting, provider),
                                  colorScheme: colorScheme,
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'Aceptados',
                                  count: _countAssigned(provider.trips),
                                  selected: _filterMode == _kAssigned,
                                  onTap: () =>
                                      _selectFilter(_kAssigned, provider),
                                  colorScheme: colorScheme,
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'En curso',
                                  count: _countInProgress(provider.trips),
                                  selected: _filterMode == _kInProgress,
                                  onTap: () =>
                                      _selectFilter(_kInProgress, provider),
                                  colorScheme: colorScheme,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (provider.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (provider.error != null)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text(provider.error!,
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: provider.loadTrips,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (filtered.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined,
                                size: 56,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text(
                              _filterMode == _kInProgress
                                  ? 'No tienes viajes en curso'
                                  : _filterMode == _kAssigned
                                      ? 'No tienes viajes aceptados'
                                      : 'No tienes viajes activos',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _TripCard(
                          trip: filtered[i],
                          onCancel: () =>
                              _confirmCancel(context, provider, filtered[i].id),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmCancel(
      BuildContext context, MyTripsProvider provider, int tripId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar viaje'),
        content: const Text('¿Estás seguro de que deseas cancelar este viaje?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.cancelTrip(tripId);
            },
            child:
                const Text('Sí, cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatefulWidget {
  final Trip trip;
  final VoidCallback onCancel;
  const _TripCard({required this.trip, required this.onCancel});

  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard> {
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

  String? _originLabel;
  String? _destinationLabel;

  @override
  void initState() {
    super.initState();
    _resolveLabels();
  }

  Future<void> _resolveLabels() async {
    final t = widget.trip;
    final needsOrigin = _needsGeocode(t.origin, t.city);
    final needsDest = t.destination.isEmpty;

    String? o;
    String? d;

    if (needsOrigin && t.originLat != 0) {
      o = await _geocodeLabel(t.originLat, t.originLng);
    }
    if (needsDest && t.destinationLat != 0) {
      d = await _geocodeLabel(t.destinationLat, t.destinationLng);
    }

    if (mounted && (o != null || d != null)) {
      setState(() {
        if (o != null) _originLabel = o;
        if (d != null) _destinationLabel = d;
      });
    }
  }

  bool _needsGeocode(String address, String city) {
    final s = address.trim();
    return s.isEmpty || s == city;
  }

  bool _hasLetters(String? s) =>
      s != null &&
      s.isNotEmpty &&
      s.contains(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ]'));

  Future<String?> _geocodeLabel(double lat, double lng) async {
    try {
      final marks = await placemarkFromCoordinates(lat, lng);
      if (marks.isEmpty) return null;
      final m = marks.first;

      final name = m.name ?? '';
      final locality = m.locality ?? '';
      if (_hasLetters(name) && name != locality) return name;

      final thoroughfare = m.thoroughfare ?? '';
      if (_hasLetters(thoroughfare)) return thoroughfare;

      final sub = m.subLocality ?? '';
      if (_hasLetters(sub)) return sub;

      return _hasLetters(locality) ? locality : null;
    } catch (_) {
      return null;
    }
  }

  String _formatDate(String raw) {
    try {
      final datePart = raw.split('T').first;
      final parts = datePart.split('-');
      if (parts.length < 3) return raw;
      final day = int.parse(parts[2]);
      final month = int.parse(parts[1]);
      return '$day de ${_months[month]}';
    } catch (_) {
      return raw;
    }
  }

  String _formatHour(String raw) {
    try {
      final timePart = raw.contains('T') ? raw.split('T').last : raw;
      final cleaned = timePart.replaceAll('Z', '');
      final colonParts = cleaned.split(':');
      if (colonParts.length >= 2) {
        return '${colonParts[0].padLeft(2, '0')}:${colonParts[1].padLeft(2, '0')}';
      }
      return raw;
    } catch (_) {
      return raw;
    }
  }

  String _shortPlace(String full) => full.split(',').first.trim();

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final colorScheme = Theme.of(context).colorScheme;
    final origin = _originLabel ?? _shortPlace(trip.origin);
    final destination = _destinationLabel ?? _shortPlace(trip.destination);
    final routeText = (origin.isEmpty && destination.isEmpty)
        ? '(sin ruta)'
        : '${origin.isEmpty ? '–' : origin} → ${destination.isEmpty ? '–' : destination}';
    final dateStr = '${_formatDate(trip.date)} · ${_formatHour(trip.hour)} hrs';
    final weightStr = trip.description != null && trip.description!.isNotEmpty
        ? '${trip.description} · ${trip.approxWeight.toInt()} kg'
        : '${trip.approxWeight.toInt()} kg';

    final inProgress = RideStatus.isInCourse(trip.status);

    return GestureDetector(
      onTap: inProgress
          ? () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TripInProgressScreen(trip: trip),
              ))
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: inProgress
              ? Border.all(color: colorScheme.primary.withValues(alpha: 0.4))
              : trip.status == RideStatus.assigned
                  ? Border.all(
                      color: colorScheme.secondary.withValues(alpha: 0.4))
                  : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined,
                      color: colorScheme.primary, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      routeText,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ProposalBadge(trip: trip, colorScheme: colorScheme),
                ],
              ),
              const SizedBox(height: 10),
              Row(children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.inventory_2_outlined,
                    size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    weightStr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(PaymentMethodInfo.icon(trip.paymentMethod),
                    size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  PaymentMethodInfo.label(trip.paymentMethod),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ]),
              _ProposalsSection(trip: trip),
              if (inProgress) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TripInProgressScreen(trip: trip),
                      ),
                    ),
                    icon: const Icon(Icons.navigation_rounded, size: 18),
                    label: const Text('Ver viaje en curso',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
              if (trip.status == RideStatus.pending) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: widget.onCancel,
                    style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error),
                    child: const Text('Cancelar viaje'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProposalBadge extends StatefulWidget {
  final Trip trip;
  final ColorScheme colorScheme;
  const _ProposalBadge({required this.trip, required this.colorScheme});

  @override
  State<_ProposalBadge> createState() => _ProposalBadgeState();
}

class _ProposalBadgeState extends State<_ProposalBadge> {
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.trip.driverId == null) _load();
  }

  Future<void> _load() async {
    try {
      final response =
          await context.read<ApiService>().getProposalsByRide(widget.trip.id);
      final d1 = response.data;
      final list = d1 is List
          ? d1
          : (d1['proposals'] ?? d1['data'] ?? []) as List? ?? [];
      final pending = list.where((e) {
        final m = e as Map<String, dynamic>;
        return (m['idstatus'] ?? m['status'] ?? 0) == 2;
      }).length;
      if (mounted) setState(() => _pendingCount = pending);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    if (widget.trip.driverId != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Reservado',
          style: TextStyle(
            color: cs.onPrimaryContainer,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    if (_pendingCount == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$_pendingCount ${_pendingCount == 1 ? 'pendiente' : 'pendientes'}',
        style: const TextStyle(
          color: Color(0xFFE07B2A),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProposalsSection extends StatefulWidget {
  final Trip trip;
  const _ProposalsSection({required this.trip});

  @override
  State<_ProposalsSection> createState() => _ProposalsSectionState();
}

class _ProposalsSectionState extends State<_ProposalsSection> {
  List<Proposal>? _proposals;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final response =
          await context.read<ApiService>().getProposalsByRide(widget.trip.id);
      final d2 = response.data;
      final list2 = d2 is List
          ? d2
          : (d2['proposals'] ?? d2['data'] ?? []) as List? ?? [];
      final basic = list2
          .map((e) => Proposal.fromJson(e as Map<String, dynamic>))
          .toList();
      final enriched = await Future.wait(basic.map(enrichProposal));
      if (mounted) setState(() => _proposals = enriched);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_proposals == null) {
      return const SizedBox.shrink();
    }

    final assigned = widget.trip.driverId != null;
    final visible = assigned
        ? _proposals!.where((p) => p.status == 1).toList()
        : _proposals!.where((p) => p.status == 2).toList();

    if (assigned && visible.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Row(
          children: [
            Icon(assigned ? Icons.verified_user_outlined : Icons.people_outline,
                size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              assigned
                  ? 'Conductor asignado'
                  : visible.isEmpty
                      ? 'Propuestas recibidas'
                      : '${visible.length} ${visible.length == 1 ? 'propuesta recibida' : 'propuestas recibidas'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (visible.isEmpty)
          Text(
            'No has recibido ninguna propuesta',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          )
        else
          ...visible.map((p) => _ProposalRow(
                proposal: p,
                tripId: widget.trip.id,
                readOnly: assigned,
                onAccepted: _load,
              )),
      ],
    );
  }
}

class _ProposalRow extends StatelessWidget {
  final Proposal proposal;
  final int tripId;
  final bool readOnly;
  final VoidCallback onAccepted;
  const _ProposalRow({
    required this.proposal,
    required this.tripId,
    this.readOnly = false,
    required this.onAccepted,
  });

  static const _avatarColors = [
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
    Color(0xFFE65100),
    Color(0xFF37474F),
  ];

  Color _avatarColor(String name) {
    final idx = name.isNotEmpty ? name.codeUnitAt(0) % _avatarColors.length : 0;
    return _avatarColors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final driver = proposal.driver;
    final driverName =
        driver != null ? '${driver.name} ${driver.lastname}' : 'Conductor';
    final initial = driverName.isNotEmpty ? driverName[0].toUpperCase() : 'C';
    final rating = driver?.rating;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ProposalDetailScreen(
          proposal: proposal,
          tripId: tripId,
          readOnly: readOnly,
          onAccepted: onAccepted,
        ),
      )),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _avatarColor(initial),
              child: Text(initial,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(
                        driverName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (rating != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFFFC107)),
                      Text(
                        rating.toStringAsFixed(1),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    Text(
                      '\$${proposal.price.toStringAsFixed(0)} MXN',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (proposal.estimatedTime != null) ...[
                      const SizedBox(width: 10),
                      Icon(Icons.schedule,
                          size: 12, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(
                        proposal.estimatedTime!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border:
              selected ? null : Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.onPrimary.withValues(alpha: 0.25)
                      : colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
