import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/utils/payment_method.dart';
import '../../rating/presentation/rate_driver_screen.dart';

class ClientPaymentScreen extends StatefulWidget {
  final Trip trip;
  final Proposal proposal;
  final String? duration;

  const ClientPaymentScreen({
    super.key,
    required this.trip,
    required this.proposal,
    this.duration,
  });

  @override
  State<ClientPaymentScreen> createState() => _ClientPaymentScreenState();
}

class _ClientPaymentScreenState extends State<ClientPaymentScreen> {
  int _selectedMethod = 0;
  bool _paying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Si el viaje se solicitó con transferencia, preselecciona esa opción.
    if (PaymentMethodInfo.isTransfer(widget.trip.paymentMethod)) {
      _selectedMethod = 1;
    }
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '\$$s MXN';
  }

  String _shortPlace(String full) => full.split(',').first.trim();

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
      final day = int.parse(parts[2]);
      final month = int.parse(parts[1]);
      return '$day de ${months[month]}';
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

  Future<void> _payWithStripe() async {
    setState(() {
      _paying = true;
      _error = null;
    });

    try {
      final res = await context.read<ApiService>().createPaymentIntent({
        'amount': widget.proposal.price,
        'currency': 'mxn',
        'ride_id': widget.trip.id,
      });

      final clientSecret = res.data['client_secret'] as String?;
      if (clientSecret == null) throw Exception('Sin clientSecret');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'LogiRed',
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (mounted) _onPaymentSuccess();
    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled && mounted) {
        setState(() => _error = e.error.localizedMessage ?? 'Error en el pago');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Error al procesar el pago: $e');
    }

    if (mounted) setState(() => _paying = false);
  }

  void _onPaymentSuccess() {
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

  void _showSpeiInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transferencia SPEI / CLABE',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            const _SpeiRow(label: 'Banco', value: 'STP'),
            const _SpeiRow(label: 'CLABE', value: '646180157000000000'),
            const _SpeiRow(label: 'Beneficiario', value: 'LogiRed S.A. de C.V.'),
            _SpeiRow(label: 'Concepto', value: 'Viaje #${widget.trip.id}'),
            _SpeiRow(label: 'Monto', value: _fmt(widget.proposal.price)),
            const SizedBox(height: 16),
            Text(
              'Una vez realizada la transferencia, tu viaje quedará marcado como pagado en un plazo de 24 horas hábiles.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trip = widget.trip;
    final proposal = widget.proposal;
    final driver = proposal.driver;
    final driverName =
        driver != null ? '${driver.name} ${driver.lastname}' : 'Conductor';
    final initial = driverName.isNotEmpty ? driverName[0].toUpperCase() : 'C';

    final weightStr = trip.description != null && trip.description!.isNotEmpty
        ? '${trip.description} · ${trip.approxWeight.toInt()} kg'
        : '${trip.approxWeight.toInt()} kg';

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
        title: const Text('Pago del viaje',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¡Viaje completado!',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary)),
                    Text('Realiza el pago para finalizar',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            colorScheme: colorScheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Resumen del viaje', colorScheme, context),
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${_shortPlace(trip.origin)} → ${_shortPlace(trip.destination)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                _TripInfoRow(
                    label: 'Fecha',
                    value:
                        '${_formatDate(trip.date)} · ${_formatHour(trip.hour)} hrs'),
                _TripInfoRow(label: 'Tipo de carga', value: weightStr),
                _TripInfoRow(
                    label: 'Método de pago',
                    value: PaymentMethodInfo.label(trip.paymentMethod)),
                if (widget.duration != null)
                  _TripInfoRow(label: 'Duración', value: widget.duration!),
                const Divider(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(initial,
                          style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Conductor',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: colorScheme.onSurfaceVariant)),
                          Text(driverName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (driver?.rating != null) ...[
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFFFC107)),
                      const SizedBox(width: 3),
                      Text(driver!.rating!.toStringAsFixed(1),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            colorScheme: colorScheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Desglose de pago', colorScheme, context),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tarifa base',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            )),
                    Text(_fmt(proposal.price),
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total a pagar',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                    Text(
                      _fmt(proposal.price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Card(
            colorScheme: colorScheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionLabel('Método de pago', colorScheme, context),
                    const _StripeBadge(),
                  ],
                ),
                const SizedBox(height: 12),
                _PayMethodTile(
                  selected: _selectedMethod == 0,
                  onTap: () => setState(() => _selectedMethod = 0),
                  icon: Icons.credit_card_outlined,
                  title: 'Tarjeta de crédito / débito',
                  subtitle: '••• ••• Stripe',
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 8),
                _PayMethodTile(
                  selected: _selectedMethod == 1,
                  onTap: () => setState(() => _selectedMethod = 1),
                  icon: Icons.account_balance_outlined,
                  title: 'Transferencia bancaria',
                  subtitle: 'SPEI / CLABE',
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(_error!,
                  style: TextStyle(color: colorScheme.onErrorContainer),
                  textAlign: TextAlign.center),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _paying
                      ? null
                      : () {
                          if (_selectedMethod == 0) {
                            _payWithStripe();
                          } else {
                            _showSpeiInfo();
                          }
                        },
                  icon: _paying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.lock_outline, size: 18),
                  label: Text(
                    _paying
                        ? 'Procesando…'
                        : _selectedMethod == 0
                            ? 'Pagar ${_fmt(proposal.price)} →'
                            : 'Ver datos de transferencia',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      size: 12, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('Pago seguro con cifrado SSL',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          )),
                  const SizedBox(width: 6),
                  const _StripeBadge(small: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final ColorScheme colorScheme;
  const _Card({required this.child, required this.colorScheme});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );
}

Widget _sectionLabel(
    String text, ColorScheme colorScheme, BuildContext context) {
  return Text(
    text,
    style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
  );
}

class _TripInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _TripInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PayMethodTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;

  const _PayMethodTile({
    required this.selected,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    width: 2),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: colorScheme.primary),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StripeBadge extends StatelessWidget {
  final bool small;
  const _StripeBadge({this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8, vertical: small ? 2 : 4),
      decoration: BoxDecoration(
        color: const Color(0xFF635BFF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'stripe',
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SpeiRow extends StatelessWidget {
  final String label;
  final String value;
  const _SpeiRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
          SelectableText(value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
