import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/utils/payment_method.dart';
import '../../rating/presentation/rate_driver_screen.dart';

/// Pago en efectivo: el cliente paga en mano y espera a que el conductor
/// confirme la recepción; cuando el backend marca `payment_status = 2` se
/// muestra "Tu pago se confirmó" y se pasa a calificar al conductor.
class CashPaymentWaitScreen extends StatefulWidget {
  final Trip trip;
  final Proposal proposal;
  final String? duration;

  const CashPaymentWaitScreen({
    super.key,
    required this.trip,
    required this.proposal,
    this.duration,
  });

  @override
  State<CashPaymentWaitScreen> createState() => _CashPaymentWaitScreenState();
}

class _CashPaymentWaitScreenState extends State<CashPaymentWaitScreen> {
  Timer? _poll;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _check());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    try {
      final r = await context.read<ApiService>().getRideById(widget.trip.id);
      final rd = (r.data['ride'] ?? r.data) as Map<String, dynamic>;
      if (!PaymentStatusInfo.isPaid(rd['payment_status'])) return;
      _poll?.cancel();
      if (!mounted) return;
      setState(() => _confirmed = true);
      Future.delayed(const Duration(milliseconds: 1600), _goToRating);
    } catch (_) {}
  }

  String _formatDate(String raw) {
    try {
      final parts = raw.split('-');
      if (parts.length < 3) return raw;
      const months = [
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
        'diciembre'
      ];
      return '${int.parse(parts[2])} de ${months[int.parse(parts[1])]}';
    } catch (_) {
      return raw;
    }
  }

  String _formatHour(String raw) {
    try {
      final timePart = raw.contains('T') ? raw.split('T').last : raw;
      final parts = timePart.replaceAll('Z', '').split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      return raw;
    } catch (_) {
      return raw;
    }
  }

  void _goToRating() {
    if (!mounted) return;
    final trip = widget.trip;
    final driver = widget.proposal.driver;
    final driverName =
        driver != null ? '${driver.name} ${driver.lastname}' : 'Conductor';
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => RateDriverScreen(
        tripId: trip.id,
        driverId: driver?.iduser ?? 0,
        driverName: driverName,
        origin: trip.origin.split(',').first.trim(),
        destination: trip.destination.split(',').first.trim(),
        date: '${_formatDate(trip.date)} · ${_formatHour(trip.hour)} hrs',
        duration: widget.duration ?? '',
      ),
    ));
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '\$$s MXN';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Pago del viaje',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _confirmed
                    ? Icon(Icons.check_circle_rounded,
                        key: const ValueKey('ok'), size: 96, color: cs.primary)
                    : SizedBox(
                        key: const ValueKey('wait'),
                        width: 96,
                        height: 96,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                              strokeWidth: 5, color: cs.primary),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                _confirmed ? '¡Tu pago se confirmó!' : '¡Viaje completado!',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _confirmed
                    ? 'Gracias por viajar con LogiRed.'
                    : 'Paga ${_fmt(widget.proposal.price)} en efectivo al '
                        'conductor.\nEsperando a que confirme tu pago…',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              if (_confirmed) ...[
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _goToRating,
                  child: const Text('Calificar al conductor'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
