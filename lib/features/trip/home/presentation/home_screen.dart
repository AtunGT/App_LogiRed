import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/utils/ride_status.dart';
import '../../../../core/utils/trip_schedule.dart';

class _QuickProposal {
  final int idRide;
  final double price;
  final int rideStatus;
  final String origin;
  final String destination;
  final String date;
  final String hour;
  _QuickProposal({
    required this.idRide,
    required this.price,
    required this.rideStatus,
    required this.origin,
    required this.destination,
    required this.date,
    required this.hour,
  });
}

class HomeScreen extends StatefulWidget {
  final void Function(int index) onNavigate;
  final bool isActive;
  const HomeScreen({super.key, required this.onNavigate, this.isActive = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _QuickProposal? _actionable;

  @override
  void initState() {
    super.initState();
    _loadActionableProposal();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadActionableProposal();
    }
  }

  Future<void> _loadActionableProposal() async {
    final api = context.read<ApiService>();
    try {
      final res = await api.getMyProposals();
      final list = (res.data['proposals'] ?? res.data) as List? ?? [];
      for (final p in list) {
        final proposalStatus =
            p['idstatus'] ?? p['idproposalstatus'] ?? p['status'] ?? 0;
        if (proposalStatus != 1) continue;

        final idRide = ((p['id_ride'] ?? p['idride']) as num?)?.toInt() ?? 0;
        if (idRide == 0) continue;

        try {
          final r = await api.getRideById(idRide);
          final rd = (r.data['ride'] ?? r.data) as Map<String, dynamic>;
          final trip = Trip.fromJson(rd);

          final active = RideStatus.isInCourse(trip.status);
          final startable = trip.status == RideStatus.assigned &&
              TripSchedule.canStart(trip.date, trip.hour);
          if (active || startable) {
            if (mounted) {
              setState(() => _actionable = _QuickProposal(
                    idRide: idRide,
                    price: (p['price'] as num?)?.toDouble() ?? 0.0,
                    rideStatus: trip.status,
                    origin: trip.origin,
                    destination: trip.destination,
                    date: trip.date,
                    hour: trip.hour,
                  ));
            }
            return;
          }
        } catch (_) {}
      }
      if (mounted && _actionable != null) setState(() => _actionable = null);
    } catch (_) {}
  }

  Future<void> _openActive(BuildContext context, _QuickProposal p) async {
    final starting = !RideStatus.isInCourse(p.rideStatus);
    final api = context.read<ApiService>();
    if (starting) {
      try {
        await api.updateRideStatus(
            p.idRide, UpdateStatusRequest(status: 2).toJson());
      } catch (_) {}
    }
    if (!context.mounted) return;
    await Navigator.pushNamed(context, '/active-trip', arguments: {
      'tripId': p.idRide,
      'isDriver': true,
      'proposalPrice': p.price,
    });
    _loadActionableProposal();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LogiRed',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 24),
              _NavCard(
                icon: Icons.location_on_outlined,
                iconColor: colorScheme.primary,
                iconBg: colorScheme.primaryContainer.withValues(alpha: 0.6),
                title: 'Viajes Disponibles',
                subtitle: 'Encuentra solicitudes de transporte',
                onTap: () => widget.onNavigate(1),
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 12),
              _NavCard(
                icon: Icons.assignment_outlined,
                iconColor: const Color(0xFF92400E),
                iconBg: const Color(0xFFFEF3C7),
                title: 'Mis Propuestas',
                subtitle: 'Estado de tus propuestas enviadas',
                onTap: () => widget.onNavigate(2),
                colorScheme: colorScheme,
              ),
              if (_actionable != null) ...[
                const SizedBox(height: 12),
                _DriverQuickCard(
                  proposal: _actionable!,
                  colorScheme: colorScheme,
                  onTap: () => _openActive(context, _actionable!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverQuickCard extends StatelessWidget {
  final _QuickProposal proposal;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _DriverQuickCard({
    required this.proposal,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final inCourse = RideStatus.isInCourse(proposal.rideStatus);
    final title = inCourse ? 'Continuar viaje' : 'Iniciar viaje';
    final statusLabel = inCourse ? 'Activo' : 'Listo para salir';
    final orig = proposal.origin.split(',').first.trim();
    final dest = proposal.destination.split(',').first.trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.primary.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                inCourse
                    ? Icons.directions_car_rounded
                    : Icons.play_circle_outline_rounded,
                color: cs.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: cs.primary, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$orig → $dest',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cs.primary),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _NavCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
