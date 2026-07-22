import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/payment_method.dart';
import '../../../../core/utils/responsive.dart';

class PaymentScreen extends StatefulWidget {
  final int tripId;
  final double proposalPrice;
  final int paymentMethod;
  final String origin;
  final String destination;
  final String duration;

  const PaymentScreen({
    super.key,
    required this.tripId,
    required this.proposalPrice,
    required this.paymentMethod,
    required this.origin,
    required this.destination,
    required this.duration,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool get _isCash => !PaymentMethodInfo.isCard(widget.paymentMethod);

  bool _paid = false;
  bool _confirming = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    // Con tarjeta el pago lo hace el cliente vía Stripe: se consulta el
    // payment_status del viaje hasta que el webhook lo marque pagado.
    if (!_isCash) {
      _poll = Timer.periodic(const Duration(seconds: 4), (_) => _checkPaid());
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _checkPaid() async {
    try {
      final r = await context.read<ApiService>().getRideById(widget.tripId);
      final rd = (r.data['ride'] ?? r.data) as Map<String, dynamic>;
      if (!PaymentStatusInfo.isPaid(rd['payment_status'])) return;
      _poll?.cancel();
      if (mounted) setState(() => _paid = true);
    } catch (_) {}
  }

  Future<void> _confirmCash() async {
    setState(() => _confirming = true);
    try {
      await context.read<ApiService>().confirmCashPayment(widget.tripId);
      if (mounted) setState(() => _paid = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No se pudo confirmar el pago. Revisa tu conexión e '
              'inténtalo de nuevo.'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
    if (mounted) setState(() => _confirming = false);
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.driverMain, (route) => false);
  }

  Widget _buildAction(ColorScheme colorScheme) {
    if (_paid) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _isCash
                        ? 'Pago en efectivo confirmado'
                        : 'Pago con tarjeta completado',
                    style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _goHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Volver al inicio',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
          ),
        ],
      );
    }

    if (_isCash) {
      return SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _confirming ? null : _confirmCash,
          icon: _confirming
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.payments_outlined, size: 20),
          label: Text(
            _confirming ? 'Confirmando…' : 'Confirmar pago en efectivo',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: colorScheme.primary),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Esperando el pago con tarjeta del cliente…',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _goHome,
          child: const Text('Volver al inicio'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCash = _isCash;
    final proposalPrice = widget.proposalPrice;
    final commission = proposalPrice * 0.10;
    final netEarnings = proposalPrice - commission;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 8),
            Text(
              'LogiRed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'C',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final maxW = Responsive.maxContentWidth(context);
        final hPad = Responsive.horizontalPadding(context);
        final w = min(maxW, constraints.maxWidth);
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: w,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CompletedBanner(
                    origin: widget.origin,
                    destination: widget.destination,
                    duration: widget.duration,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 20),
                  _PaymentMethodCard(
                    isCash: isCash,
                    amount: proposalPrice,
                    colorScheme: colorScheme,
                  ),
                  if (isCash && !_paid) ...[
                    const SizedBox(height: 12),
                    _CashWarning(colorScheme: colorScheme),
                  ],
                  const SizedBox(height: 12),
                  _BreakdownCard(
                    agreedPrice: proposalPrice,
                    commission: commission,
                    net: netEarnings,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 24),
                  _buildAction(colorScheme),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  final String origin;
  final String destination;
  final String duration;
  final ColorScheme colorScheme;

  const _CompletedBanner({
    required this.origin,
    required this.destination,
    required this.duration,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: colorScheme.onPrimary, size: 20),
              const SizedBox(width: 6),
              Text(
                '¡Viaje completado!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$origin → $destination · $duration',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.85),
                ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final bool isCash;
  final double amount;
  final ColorScheme colorScheme;

  const _PaymentMethodCard({
    required this.isCash,
    required this.amount,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final fmtAmount =
        '\$${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} MXN';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Método de pago',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MethodPill(
                  label: 'Efectivo', active: isCash, colorScheme: colorScheme),
              const SizedBox(width: 8),
              _MethodPill(
                  label: 'Tarjeta', active: !isCash, colorScheme: colorScheme),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'A cobrar al cliente:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
              ),
              Text(
                fmtAmount,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MethodPill extends StatelessWidget {
  final String label;
  final bool active;
  final ColorScheme colorScheme;

  const _MethodPill({
    required this.label,
    required this.active,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: active ? colorScheme.onSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: active ? null : Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:
                  active ? colorScheme.surface : colorScheme.onSurfaceVariant,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
      ),
    );
  }
}

class _CashWarning extends StatelessWidget {
  final ColorScheme colorScheme;
  const _CashWarning({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Solicita el pago en efectivo al cliente antes de marcar el viaje como finalizado.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7B5800),
            ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final double agreedPrice;
  final double commission;
  final double net;
  final ColorScheme colorScheme;

  const _BreakdownCard({
    required this.agreedPrice,
    required this.commission,
    required this.net,
    required this.colorScheme,
  });

  String _fmt(double v) =>
      '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} MXN';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Desglose del pago',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 14),
          _BreakdownRow(
            label: 'Tarifa acordada',
            value: _fmt(agreedPrice),
            valueColor: colorScheme.onSurface,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _BreakdownRow(
            label: 'Comisión LogiRed (10%)',
            value: '−${_fmt(commission)}',
            valueColor: Colors.red,
            colorScheme: colorScheme,
          ),
          Divider(
              height: 20, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          _BreakdownRow(
            label: 'Tu ganancia neta',
            value: _fmt(net),
            valueColor: colorScheme.onSurface,
            colorScheme: colorScheme,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final ColorScheme colorScheme;
  final bool bold;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.colorScheme,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
