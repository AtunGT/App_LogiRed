import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/utils/payment_method.dart';
import '../../../../core/utils/responsive.dart';
import '../../../main/widgets/driver_app_bar.dart';
import 'available_trips_provider.dart';

class AvailableTripsScreen extends StatelessWidget {
  const AvailableTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AvailableTripsProvider()..loadCityAndSearch(),
      child: Consumer<AvailableTripsProvider>(
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
                  padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Viajes Disponibles',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Explora solicitudes de transporte y envía propuestas a los clientes',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
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

  Widget _buildBody(BuildContext context, AvailableTripsProvider provider,
      ColorScheme colorScheme, double hPad) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined,
                size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(provider.error!,
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: provider.loadCityAndSearch,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (provider.trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_off_outlined,
                size: 56, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Sin viajes disponibles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'No hay solicitudes en tu ciudad aún',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: provider.searchTrips,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
        itemCount: provider.trips.length,
        itemBuilder: (context, i) => _TripCard(
          trip: provider.trips[i],
          onDetail: () {
            final tripId = provider.trips[i].id;
            Navigator.pushNamed(
              context,
              '/driver-trip-detail',
              arguments: tripId,
            ).then((sent) {
              if (sent == true) provider.excludeTrip(tripId);
            });
          },
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onDetail;

  const _TripCard({required this.trip, required this.onDetail});

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
      return '${_weekdays[d.weekday - 1]} ${d.day} de ${_months[d.month - 1]}';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weight = trip.approxWeight % 1 == 0
        ? '${trip.approxWeight.toInt()} kg'
        : '${trip.approxWeight} kg';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${trip.origin} → ${trip.destination}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  label: _formatDate(trip.date),
                  colorScheme: colorScheme,
                ),
                _InfoChip(
                  icon: Icons.access_time_outlined,
                  label: '${_formatHour(trip.hour)} hrs',
                  colorScheme: colorScheme,
                ),
                _InfoChip(
                  icon: Icons.trending_up,
                  label: weight,
                  colorScheme: colorScheme,
                ),
                _InfoChip(
                  icon: PaymentMethodInfo.icon(trip.paymentMethod),
                  label: PaymentMethodInfo.label(trip.paymentMethod),
                  colorScheme: colorScheme,
                ),
              ],
            ),
            if (trip.city.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    trip.city,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
            if (trip.description != null && trip.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                trip.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onDetail,
                icon: const SizedBox.shrink(),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver detalles',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward,
                        size: 16, color: colorScheme.onPrimary),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _InfoChip(
      {required this.icon, required this.label, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
