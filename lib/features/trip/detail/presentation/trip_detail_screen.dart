import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/payment_method.dart';
import 'trip_detail_provider.dart';

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

class TripDetailScreen extends StatelessWidget {
  final int tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TripDetailProvider()..loadTrip(tripId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Detalle del viaje')),
        body: Consumer<TripDetailProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(
                  child: Text(provider.error!,
                      style: const TextStyle(color: Colors.red)));
            }
            if (provider.trip == null) return const SizedBox();
            final trip = provider.trip!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _DetailSection(
                    title: 'Origen',
                    value: trip.origin,
                    icon: Icons.location_on,
                    iconColor: Colors.green),
                _DetailSection(
                    title: 'Destino',
                    value: trip.destination,
                    icon: Icons.flag,
                    iconColor: Colors.red),
                _DetailSection(
                    title: 'Ciudad',
                    value: trip.city,
                    icon: Icons.location_city),
                _DetailSection(
                    title: 'Fecha',
                    value: trip.date,
                    icon: Icons.calendar_today),
                _DetailSection(
                    title: 'Hora',
                    value: _formatHour(trip.hour),
                    icon: Icons.access_time),
                _DetailSection(
                    title: 'Peso aprox.',
                    value: '${trip.approxWeight} kg',
                    icon: Icons.scale),
                _DetailSection(
                    title: 'Método de pago',
                    value: PaymentMethodInfo.label(trip.paymentMethod),
                    icon: PaymentMethodInfo.icon(trip.paymentMethod)),
                if (trip.distanceKm != null)
                  _DetailSection(
                      title: 'Distancia',
                      value: '${trip.distanceKm!.toStringAsFixed(1)} km',
                      icon: Icons.route),
                if (trip.description != null && trip.description!.isNotEmpty)
                  _DetailSection(
                      title: 'Descripción',
                      value: trip.description!,
                      icon: Icons.notes),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                            context, '/trip-map',
                            arguments: trip.id),
                        icon: const Icon(Icons.map),
                        label: const Text('Ver mapa'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                            context, '/trip-proposals',
                            arguments: trip.id),
                        icon: const Icon(Icons.local_offer),
                        label: const Text('Propuestas'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/active-trip', arguments: {
                    'tripId': trip.id,
                    'isDriver': false,
                    'proposalPrice': 0.0,
                  }),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Ver viaje activo'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  const _DetailSection(
      {required this.title,
      required this.value,
      required this.icon,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon,
                color: iconColor ?? Theme.of(context).colorScheme.primary,
                size: 22),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
