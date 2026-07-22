import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int index) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _proposalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProposalCount();
  }

  Future<void> _loadProposalCount() async {
    try {
      final res = await context.read<ApiService>().getMyAcceptedTrips();
      final list = (res.data['rides'] ?? res.data) as List? ?? [];
      if (mounted) setState(() => _proposalCount = list.length);
    } catch (_) {}
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
                badge: _proposalCount > 0 ? _proposalCount : null,
                onTap: () => widget.onNavigate(2),
                colorScheme: colorScheme,
              ),
            ],
          ),
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
  final int? badge;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _NavCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.badge,
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
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badge',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
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
    );
  }
}
