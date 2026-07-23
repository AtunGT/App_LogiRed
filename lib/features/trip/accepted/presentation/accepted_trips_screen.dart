import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/utils/payment_method.dart';
import '../../../../core/utils/ride_status.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/trip_schedule.dart';
import '../../../main/widgets/driver_app_bar.dart';
import 'accepted_trips_provider.dart';
import 'driver_proposal_detail_screen.dart';

class AcceptedTripsScreen extends StatefulWidget {
  final bool isActive;
  const AcceptedTripsScreen({super.key, this.isActive = true});

  @override
  State<AcceptedTripsScreen> createState() => _AcceptedTripsScreenState();
}

class _AcceptedTripsScreenState extends State<AcceptedTripsScreen> {
  late final AcceptedTripsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AcceptedTripsProvider(context.read<ApiService>())..loadTrips();
  }

  @override
  void didUpdateWidget(covariant AcceptedTripsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _provider.loadTrips();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _selectFilter(AcceptedTripsProvider provider, ProposalFilter filter) {
    provider.setFilter(filter);
    provider.loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<AcceptedTripsProvider>(
        builder: (context, provider, _) {
          final colorScheme = Theme.of(context).colorScheme;
          final hPad = Responsive.horizontalPadding(context);

          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLow,
            appBar: const DriverAppBar(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis Propuestas',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seguimiento de las propuestas que has enviado',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'Pendientes',
                              count: provider.countPending,
                              selected:
                                  provider.filter == ProposalFilter.pending,
                              onTap: () => _selectFilter(
                                  provider, ProposalFilter.pending),
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Aceptadas',
                              count: provider.countAccepted,
                              selected:
                                  provider.filter == ProposalFilter.accepted,
                              onTap: () => _selectFilter(
                                  provider, ProposalFilter.accepted),
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'En curso',
                              count: provider.countInProgress,
                              selected:
                                  provider.filter == ProposalFilter.inProgress,
                              onTap: () => _selectFilter(
                                  provider, ProposalFilter.inProgress),
                              colorScheme: colorScheme,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: _buildBody(context, provider, colorScheme, hPad)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AcceptedTripsProvider provider,
      ColorScheme colorScheme, double hPad) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.proposals.isEmpty) {
      final emptyMsg = provider.filter == ProposalFilter.pending
          ? 'No tienes propuestas pendientes'
          : provider.filter == ProposalFilter.accepted
              ? 'No tienes viajes reservados'
              : 'No tienes viajes en curso';
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 56,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              emptyMsg,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: provider.loadTrips,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 16),
        itemCount: provider.proposals.length,
        itemBuilder: (context, i) => _ProposalCard(
          item: provider.proposals[i],
          colorScheme: colorScheme,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                DriverProposalDetailScreen(item: provider.proposals[i]),
          )),
          onOpenActive: (start) =>
              _openActive(context, provider, provider.proposals[i], start),
        ),
      ),
    );
  }

  Future<void> _openActive(BuildContext context, AcceptedTripsProvider provider,
      DriverProposalItem item, bool start) async {
    final api = context.read<ApiService>();
    if (start) {
      try {
        await api.updateRideStatus(
            item.idRide, UpdateStatusRequest(status: 2).toJson());
      } catch (_) {}
    }
    if (!context.mounted) return;
    await Navigator.pushNamed(context, '/active-trip', arguments: {
      'tripId': item.idRide,
      'isDriver': true,
      'proposalPrice': item.price,
    });
    provider.loadTrips();
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

class _ProposalCard extends StatelessWidget {
  final DriverProposalItem item;
  final ColorScheme colorScheme;
  final VoidCallback onTap;
  final void Function(bool start) onOpenActive;

  const _ProposalCard({
    required this.item,
    required this.colorScheme,
    required this.onTap,
    required this.onOpenActive,
  });

  static const _weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
  static const _months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic'
  ];

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      return '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';
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
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      return raw;
    } catch (_) {
      return raw;
    }
  }

  String _shortPlace(String full) => full.split(',').first.trim();

  bool get _rideTakenByOther =>
      item.status != 1 &&
      item.rideLoaded &&
      item.rideStatus != 0 &&
      item.rideStatus != RideStatus.pending;

  (String label, Color bg, Color text) _statusInfo() {
    if (item.status == 1) {
      if (RideStatus.isInCourse(item.rideStatus)) {
        return ('En curso', const Color(0xFFE3F2FD), const Color(0xFF1565C0));
      }
      return ('Reservado', const Color(0xFFE8F5E9), const Color(0xFF2E7D32));
    }
    if (item.status == 3) {
      return ('Rechazada', const Color(0xFFFFEBEE), const Color(0xFFC62828));
    }
    if (item.rideStatus == RideStatus.cancelled) {
      return (
        item.cancelReason == CancelReason.expired
            ? 'Viaje expirado'
            : 'Viaje cancelado',
        const Color(0xFFECEFF1),
        const Color(0xFF546E7A)
      );
    }
    if (item.rideGone) {
      return ('No disponible', const Color(0xFFECEFF1),
          const Color(0xFF546E7A));
    }
    if (_rideTakenByOther) {
      return ('No seleccionada', const Color(0xFFECEFF1),
          const Color(0xFF546E7A));
    }
    return ('Pendiente', const Color(0xFFFFF8E1), const Color(0xFFE65100));
  }

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusBg, statusText) = _statusInfo();
    final weight = item.approxWeight % 1 == 0
        ? '${item.approxWeight.toInt()} kg'
        : '${item.approxWeight} kg';
    final price = item.price % 1 == 0
        ? '\$${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} MXN'
        : '\$${item.price} MXN';

    final infoParts = [
      _formatDate(item.date),
      '${_formatHour(item.hour)} hrs',
      weight,
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${_shortPlace(item.origin)} → ${_shortPlace(item.destination)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              infoParts.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PaymentMethodInfo.icon(item.paymentMethod),
                    size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 5),
                Text(
                  PaymentMethodInfo.label(item.paymentMethod),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    item.clientName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  price,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Ver detalles',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            _actionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context) {
    if (item.status != 1 || !item.rideLoaded) return const SizedBox.shrink();
    if (RideStatus.isInCourse(item.rideStatus)) {
      return _btn(context, 'Continuar viaje', true, () => onOpenActive(false),
          Icons.navigation_rounded);
    }
    if (TripSchedule.canStart(item.date, item.hour)) {
      return _btn(context, 'Iniciar viaje', true, () => onOpenActive(true),
          Icons.play_arrow_rounded);
    }
    final when = TripSchedule.label(item.date, item.hour);
    return _btn(context, when.isEmpty ? 'Aún no disponible' : 'Inicia $when',
        false, null, Icons.schedule);
  }

  Widget _btn(BuildContext context, String label, bool enabled,
      VoidCallback? onTap, IconData icon) {
    final cs = colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton.icon(
          onPressed: enabled ? onTap : null,
          icon: Icon(icon, size: 18),
          label:
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            disabledBackgroundColor: cs.surfaceContainerHighest,
            disabledForegroundColor: cs.onSurfaceVariant,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
