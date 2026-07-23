import 'package:flutter/material.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/utils/payment_method.dart';
import '../../../../core/utils/ride_status.dart';

class DriverProposalDetailScreen extends StatelessWidget {
  final DriverProposalItem item;
  const DriverProposalDetailScreen({super.key, required this.item});

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      final day = d.day.toString().padLeft(2, '0');
      final month = d.month.toString().padLeft(2, '0');
      return '$day/$month/${d.year}';
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
    final colorScheme = Theme.of(context).colorScheme;
    final (statusLabel, statusBg, statusText) = _statusInfo();
    final price = item.price % 1 == 0
        ? '\$${item.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} MXN'
        : '\$${item.price} MXN';

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
          'Tu propuesta',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          item.clientName.isNotEmpty
                              ? item.clientName[0].toUpperCase()
                              : 'C',
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.clientName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
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
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos del viaje',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 10),
                      _infoRow('Origen', item.origin, colorScheme, context),
                      _infoRow(
                          'Destino', item.destination, colorScheme, context),
                      _infoRow(
                        'Peso aproximado',
                        '${item.approxWeight % 1 == 0 ? item.approxWeight.toInt() : item.approxWeight}KG',
                        colorScheme,
                        context,
                      ),
                      _infoRow('Fecha', _formatDate(item.date), colorScheme,
                          context),
                      _infoRow(
                          'Hora', _formatHour(item.hour), colorScheme, context),
                      _infoRow(
                          'Método de pago',
                          PaymentMethodInfo.label(item.paymentMethod),
                          colorScheme,
                          context),
                      if (item.description != null &&
                          item.description!.isNotEmpty)
                        _infoRow('Descripción', item.description!, colorScheme,
                            context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tu oferta',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                ),
                Text(
                  price,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          if (item.comment != null && item.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu comentario',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '"${item.comment!}"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            item.status == 1
                ? (RideStatus.isInCourse(item.rideStatus))
                    ? 'Este viaje ya está en curso.'
                    : 'El cliente reservó este viaje contigo.'
                : item.status == 3
                    ? 'El cliente rechazó esta propuesta.'
                    : item.rideStatus == RideStatus.cancelled
                        ? (item.cancelReason == CancelReason.expired
                            ? 'El viaje expiró porque nadie lo tomó a tiempo.'
                            : 'El cliente canceló este viaje.')
                        : item.rideGone
                            ? 'Este viaje ya no está disponible.'
                            : _rideTakenByOther
                                ? 'El viaje ya fue asignado a otro conductor.'
                                : 'Tu propuesta está a la espera de que el cliente la acepte.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

Widget _infoRow(
    String label, String value, ColorScheme colorScheme, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
