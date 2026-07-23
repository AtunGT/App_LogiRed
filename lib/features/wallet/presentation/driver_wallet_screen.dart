import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/model/models.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/payment_method.dart';
import 'driver_wallet_provider.dart';

const _monthsAbbr = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

class DriverWalletScreen extends StatefulWidget {
  final bool isActive;
  const DriverWalletScreen({super.key, this.isActive = true});

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen> {
  late final DriverWalletProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = DriverWalletProvider(context.read<ApiService>())..load();
  }

  @override
  void didUpdateWidget(covariant DriverWalletScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _provider.load();
    }
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<DriverWalletProvider>(
        builder: (context, provider, _) {
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLow,
            body: SafeArea(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? _ErrorView(
                          message: provider.error!,
                          onRetry: provider.load,
                        )
                      : RefreshIndicator(
                          onRefresh: provider.load,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Image.asset('assets/images/logo.png',
                                      height: 26),
                                  const SizedBox(width: 8),
                                  Text('LogiRed',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold)),
                                ]),
                                const SizedBox(height: 18),
                                Text(
                                  'Cartera',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tus ganancias y movimientos',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: colorScheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: 16),
                                if (provider.partialError != null) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      provider.partialError!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: const Color(0xFF7B5800)),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (provider.wallet.blocked) ...[
                                  _BlockedBanner(colorScheme: colorScheme),
                                  const SizedBox(height: 12),
                                ],
                                _BalanceCard(
                                  wallet: provider.wallet,
                                  colorScheme: colorScheme,
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SectionLabel('Ganancias',
                                          colorScheme: colorScheme),
                                    ),
                                    _PeriodToggle(
                                      period: provider.period,
                                      onChanged: provider.setPeriod,
                                      colorScheme: colorScheme,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _EarningsCard(
                                  key: ValueKey(provider.period),
                                  entries: provider.chartEntries,
                                  period: provider.period,
                                  colorScheme: colorScheme,
                                ),
                                const SizedBox(height: 20),
                                _SectionLabel('Movimientos',
                                    colorScheme: colorScheme),
                                const SizedBox(height: 8),
                                if (provider.movements.isEmpty)
                                  _EmptyCard(
                                    text: 'Aún no tienes movimientos',
                                    colorScheme: colorScheme,
                                  )
                                else ...[
                                  _MovementsCard(
                                    movements: provider.movements,
                                    colorScheme: colorScheme,
                                  ),
                                  if (provider.hasMore) ...[
                                    const SizedBox(height: 8),
                                    Center(
                                      child: provider.isLoadingMore
                                          ? const Padding(
                                              padding: EdgeInsets.all(8),
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2),
                                              ),
                                            )
                                          : TextButton(
                                              onPressed: provider.loadMore,
                                              child: const Text(
                                                  'Ver más movimientos'),
                                            ),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        ),
            ),
          );
        },
      ),
    );
  }
}

class _BlockedBanner extends StatelessWidget {
  final ColorScheme colorScheme;
  const _BlockedBanner({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 20, color: colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Alcanzaste el límite de deuda. Liquida tu comisión pendiente '
              'para seguir aceptando viajes.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final DriverWallet wallet;
  final ColorScheme colorScheme;
  const _BalanceCard({required this.wallet, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final negative = wallet.balance < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo actual',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            Money.mxn(wallet.balance),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: negative ? Colors.red : colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _BalanceCell(
                  label: 'Comisión por pagar',
                  value: Money.format(wallet.pendingCommission),
                  valueColor:
                      wallet.pendingCommission > 0 ? Colors.red : null,
                  colorScheme: colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BalanceCell(
                  label: 'Por cobrar',
                  value: Money.format(wallet.pendingEarnings),
                  colorScheme: colorScheme,
                ),
              ),
            ],
          ),
          if (wallet.debtLimit > 0) ...[
            const SizedBox(height: 12),
            Text(
              'Límite de deuda: ${Money.format(wallet.debtLimit)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final ColorScheme colorScheme;
  const _BalanceCell({
    required this.label,
    required this.value,
    this.valueColor,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final WalletPeriod period;
  final ValueChanged<WalletPeriod> onChanged;
  final ColorScheme colorScheme;
  const _PeriodToggle({
    required this.period,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill('Día', WalletPeriod.day, context),
        const SizedBox(width: 6),
        _pill('Mes', WalletPeriod.month, context),
      ],
    );
  }

  Widget _pill(String label, WalletPeriod value, BuildContext context) {
    final active = period == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? colorScheme.onSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border:
              active ? null : Border.all(color: colorScheme.outlineVariant),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: active
                    ? colorScheme.surface
                    : colorScheme.onSurfaceVariant,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}

class _EarningsCard extends StatefulWidget {
  final List<WalletSummaryEntry> entries;
  final WalletPeriod period;
  final ColorScheme colorScheme;
  const _EarningsCard({
    super.key,
    required this.entries,
    required this.period,
    required this.colorScheme,
  });

  @override
  State<_EarningsCard> createState() => _EarningsCardState();
}

class _EarningsCardState extends State<_EarningsCard> {
  late int _selected = widget.entries.length - 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;
    final entries = widget.entries;
    final maxNet = entries.fold<double>(0, (m, e) => e.net > m ? e.net : m);
    final trips = entries.fold<int>(0, (s, e) => s + e.trips);
    final gross = entries.fold<double>(0, (s, e) => s + e.gross);
    final commission = entries.fold<double>(0, (s, e) => s + e.commission);
    final net = entries.fold<double>(0, (s, e) => s + e.net);
    final sel = entries[_selected.clamp(0, entries.length - 1)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (maxNet <= 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'Sin viajes en este periodo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            )
          else ...[
            Text(
              '${_periodLabel(sel.period, widget.period, long: true)} · '
              '${sel.trips} ${sel.trips == 1 ? 'viaje' : 'viajes'} · '
              'Neto ${Money.format(sel.net)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(entries.length, (i) {
                  final e = entries[i];
                  final h = maxNet > 0 ? 110 * (e.net / maxNet) : 0.0;
                  final selected = i == _selected;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selected = i),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 22,
                          height: e.net > 0 ? h.clamp(4.0, 110.0) : 3,
                          decoration: BoxDecoration(
                            color: e.net > 0
                                ? (selected
                                    ? colorScheme.primary
                                    : colorScheme.primary
                                        .withValues(alpha: 0.35))
                                : colorScheme.outlineVariant,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(entries.length, (i) {
                return Expanded(
                  child: Text(
                    _periodLabel(entries[i].period, widget.period),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: i == _selected
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              i == _selected ? FontWeight.w600 : null,
                        ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _totalCell('Viajes', '$trips', context),
                _totalCell('Bruto', Money.format(gross), context),
                _totalCell('Comisión', Money.format(commission), context),
                _totalCell('Neto', Money.format(net), context),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _totalCell(String label, String value, BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: widget.colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  static String _periodLabel(String period, WalletPeriod p,
      {bool long = false}) {
    final parts = period.split('-');
    if (p == WalletPeriod.day && parts.length >= 3) {
      final day = int.tryParse(parts[2]) ?? 0;
      final month = int.tryParse(parts[1]) ?? 1;
      return long ? '$day ${_monthsAbbr[month - 1]}' : '$day';
    }
    if (parts.length >= 2) {
      final month = int.tryParse(parts[1]) ?? 1;
      return long ? '${_monthsAbbr[month - 1]} ${parts[0]}' : _monthsAbbr[month - 1];
    }
    return period;
  }
}

class _MovementsCard extends StatelessWidget {
  final List<WalletMovement> movements;
  final ColorScheme colorScheme;
  const _MovementsCard({required this.movements, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: List.generate(movements.length, (i) {
          final m = movements[i];
          return Column(
            children: [
              _MovementTile(movement: m, colorScheme: colorScheme),
              if (i != movements.length - 1)
                Divider(
                  height: 1,
                  indent: 60,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final WalletMovement movement;
  final ColorScheme colorScheme;
  const _MovementTile({required this.movement, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final m = movement;
    final positive = m.amount >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon(m.type), size: 19, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(m),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle(m),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Money.signed(m.amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: positive ? Colors.green : Colors.red,
                ),
          ),
        ],
      ),
    );
  }

  static IconData _icon(int type) => switch (type) {
        WalletMovement.typeCashTrip => Icons.payments_outlined,
        WalletMovement.typeCardTrip => Icons.credit_card_outlined,
        WalletMovement.typeDebtPayment => Icons.check_circle_outline,
        WalletMovement.typePayout => Icons.savings_outlined,
        _ => Icons.swap_horiz,
      };

  static String _title(WalletMovement m) {
    switch (m.type) {
      case WalletMovement.typeCashTrip:
      case WalletMovement.typeCardTrip:
        if (m.origin.isNotEmpty && m.destination.isNotEmpty) {
          return '${m.origin} → ${m.destination}';
        }
        return m.idRide != null ? 'Viaje #${m.idRide}' : 'Viaje';
      case WalletMovement.typeDebtPayment:
        return 'Pago de comisión';
      case WalletMovement.typePayout:
        return 'Retiro de ganancias';
      default:
        return 'Movimiento';
    }
  }

  static String _subtitle(WalletMovement m) {
    final parts = <String>[];
    final date = _fmtDate(m.createdAt);
    if (date.isNotEmpty) parts.add(date);
    if (m.type == WalletMovement.typeCashTrip ||
        m.type == WalletMovement.typeCardTrip) {
      parts.add(PaymentMethodInfo.label(m.paymentMethod ?? m.type));
      if (m.fare != null) parts.add('Tarifa ${Money.format(m.fare!)}');
    }
    return parts.join(' · ');
  }

  static String _fmtDate(String iso) {
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_monthsAbbr[d.month - 1]}, $hh:$mm';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final ColorScheme colorScheme;
  const _SectionLabel(this.text, {required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  final ColorScheme colorScheme;
  const _EmptyCard({required this.text, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_outlined,
              size: 48, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
