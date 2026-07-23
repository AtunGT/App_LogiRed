import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/network/api_service.dart';
import '../../core/network/model/models.dart';
import '../../core/utils/ride_status.dart';
import '../trip/home/presentation/home_provider.dart';
import '../trip/inprogress/presentation/trip_in_progress_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;
  final bool isActive;
  const ClientHomeScreen(
      {required this.onNavigate, this.isActive = true, super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  Trip? _inProgressTrip;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().load();
    });
    _loadInProgressTrip();
  }

  @override
  void didUpdateWidget(covariant ClientHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      context.read<HomeProvider>().load();
      _loadInProgressTrip();
    }
  }

  Future<void> _loadInProgressTrip() async {
    try {
      final res = await context.read<ApiService>().getMyRequestedTrips();
      final list = (res.data['rides'] ?? res.data) as List? ?? [];
      for (final e in list) {
        final trip = Trip.fromJson(e as Map<String, dynamic>);
        if (RideStatus.isInCourse(trip.status)) {
          if (mounted) setState(() => _inProgressTrip = trip);
          return;
        }
      }
      if (mounted && _inProgressTrip != null) {
        setState(() => _inProgressTrip = null);
      }
    } catch (_) {}
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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 8),
            Text(
              'LogiRed',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<HomeProvider>(
        builder: (context, dash, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ActionCard(
                icon: Icons.add_circle_outline,
                iconColor: colorScheme.primary,
                iconBg: colorScheme.primaryContainer,
                title: 'Publicar Viaje',
                subtitle: 'Publica una nueva solicitud de transporte',
                onTap: () => widget.onNavigate(1),
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.assignment_outlined,
                iconColor: const Color(0xFFE07B2A),
                iconBg: const Color(0xFFFFF0E0),
                title: 'Mis Viajes',
                subtitle: 'Ver propuestas recibidas',
                badge: dash.pendingTrips > 0 ? dash.pendingTrips : null,
                onTap: () => widget.onNavigate(2),
              ),
              const SizedBox(height: 12),
              if (_inProgressTrip != null) ...[
                _QuickAccessCard(
                  icon: Icons.local_shipping_outlined,
                  statusLabel: 'En curso',
                  title: 'Ver viaje en curso',
                  origin: _inProgressTrip!.origin,
                  destination: _inProgressTrip!.destination,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TripInProgressScreen(trip: _inProgressTrip!),
                      ),
                    );
                    _loadInProgressTrip();
                  },
                ),
                const SizedBox(height: 12),
              ],
              _SummaryCard(
                activos: dash.acceptedTrips,
                propuestas: dash.pendingTrips,
                completados: dash.completedTrips,
                isLoading: dash.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final int? badge;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$badge',
                              style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
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
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int activos;
  final int propuestas;
  final int completados;
  final bool isLoading;

  const _SummaryCard({
    required this.activos,
    required this.propuestas,
    required this.completados,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bar_chart_rounded,
                      color: colorScheme.secondary, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  'Resumen',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _StatRow(label: 'Viajes activos', value: activos),
              const Divider(height: 24),
              _StatRow(label: 'Propuestas recibidas', value: propuestas),
              const Divider(height: 24),
              _StatRow(label: 'Completados', value: completados),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String statusLabel;
  final String title;
  final String origin;
  final String destination;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.statusLabel,
    required this.title,
    required this.origin,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final orig = origin.split(',').first.trim();
    final dest = destination.split(',').first.trim();

    return Card(
      elevation: 0,
      color: cs.primaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: cs.onPrimary, size: 24),
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
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
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
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final int value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Text(
          '$value',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
