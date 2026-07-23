import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/trip_history_repository.dart';
import '../../../../core/local/token_manager.dart';
import '../../../../core/network/model/models.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/ride_status.dart';
import '../../proposals/proposal_enrichment.dart';
import 'history_trip_detail_screen.dart';
import 'trip_history_provider.dart';

class TripHistoryScreen extends StatefulWidget {
  final bool showBackButton;
  final bool isActive;
  const TripHistoryScreen(
      {super.key, this.showBackButton = false, this.isActive = true});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  late final TripHistoryProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = TripHistoryProvider(
        context.read<TripHistoryRepository>(), context.read<TokenManager>())
      ..loadHistory();
  }

  @override
  void didUpdateWidget(covariant TripHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) _provider.loadHistory();
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
      child: _HistoryBody(showBackButton: widget.showBackButton),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  final bool showBackButton;
  const _HistoryBody({required this.showBackButton});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TripHistoryProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLow,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: provider.loadHistory,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            if (showBackButton) ...[
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                },
                                icon: Icon(Icons.arrow_back,
                                    color: colorScheme.onSurface),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Image.asset('assets/images/logo.png', height: 26),
                            const SizedBox(width: 8),
                            Text('LogiRed',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 18),
                          Text(
                            'Historial de viajes',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tus viajes completados y cancelados',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          if (!provider.isLoading &&
                              provider.filteredTrips.isNotEmpty)
                            _CountChip(
                              completed: provider.filteredTrips
                                  .where(
                                      (t) => t.status == RideStatus.completed)
                                  .length,
                              cancelled: provider.filteredTrips
                                  .where(
                                      (t) => t.status == RideStatus.cancelled)
                                  .length,
                              colorScheme: colorScheme,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (provider.isLoading)
                    const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()))
                  else if (provider.error != null)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text(provider.error!,
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 16),
                            FilledButton(
                                onPressed: provider.loadHistory,
                                child: const Text('Reintentar')),
                          ],
                        ),
                      ),
                    )
                  else if (provider.filteredTrips.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history,
                                size: 56,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text('Sin viajes en el historial',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: provider.filteredTrips.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _HistoryCard(trip: provider.filteredTrips[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CountChip extends StatelessWidget {
  final int completed;
  final int cancelled;
  final ColorScheme colorScheme;
  const _CountChip({
    required this.completed,
    required this.cancelled,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        if (completed > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 15, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  '$completed completado${completed == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        if (cancelled > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel_outlined, size: 15, color: colorScheme.error),
                const SizedBox(width: 6),
                Text(
                  '$cancelled cancelado${cancelled == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final Trip trip;
  const _HistoryCard({required this.trip});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  Proposal? _proposal;
  bool _loadingProposal = false;

  @override
  void initState() {
    super.initState();
    if (widget.trip.status != RideStatus.cancelled) {
      _loadingProposal = true;
      _loadProposal();
    }
  }

  Future<void> _loadProposal() async {
    try {
      _proposal = await fetchAcceptedProposal(widget.trip.id);
    } catch (_) {}
    if (mounted) setState(() => _loadingProposal = false);
  }

  String _shortPlace(String full) => full.split(',').first.trim();

  static const _months = [
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
    'diciembre',
  ];

  String _formatDate(String raw) {
    try {
      final datePart = raw.split('T').first;
      final parts = datePart.split('-');
      if (parts.length < 3) return raw;
      final day = int.parse(parts[2]);
      final month = int.parse(parts[1]);
      return '$day de ${_months[month]}';
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
    final trip = widget.trip;
    final driver = _proposal?.driver;
    final driverName =
        driver != null ? '${driver.name} ${driver.lastname}' : null;
    final initial = driverName != null && driverName.isNotEmpty
        ? driverName[0].toUpperCase()
        : '?';

    final weightStr = trip.description != null && trip.description!.isNotEmpty
        ? '${trip.description} · ${trip.approxWeight.toInt()} kg'
        : '${trip.approxWeight.toInt()} kg';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  trip.destination.isEmpty
                      ? _shortPlace(trip.origin)
                      : '${_shortPlace(trip.origin)} → ${_shortPlace(trip.destination)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: trip.status == RideStatus.cancelled
                      ? colorScheme.errorContainer
                      : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trip.status == RideStatus.cancelled
                      ? (trip.cancelReason == CancelReason.expired
                          ? 'Expiró'
                          : 'Cancelado')
                      : 'Completado',
                  style: TextStyle(
                    color: trip.status == RideStatus.cancelled
                        ? colorScheme.error
                        : colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (trip.date.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${_formatDate(trip.date)} · ${_formatHour(trip.hour)} hrs',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          if (trip.approxWeight > 0 ||
              (trip.description?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 2),
            Text(
              weightStr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (trip.status != RideStatus.cancelled && driverName != null) ...[
            const Divider(height: 18),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(children: [
                        if (driver?.rating != null) ...[
                          const Icon(Icons.star_rounded,
                              size: 12, color: Color(0xFFFFC107)),
                          const SizedBox(width: 2),
                          Text(
                            driver!.rating!.toStringAsFixed(1),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (_proposal?.estimatedTime != null)
                          Text(
                            _proposal!.estimatedTime!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                          ),
                      ]),
                    ],
                  ),
                ),
                if (_proposal != null)
                  Text(
                    '\$${_proposal!.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} MXN',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
              ],
            ),
          ] else if (trip.status != RideStatus.cancelled &&
              _proposal != null) ...[
            const Divider(height: 18),
            Row(
              children: [
                Icon(Icons.payments_outlined,
                    size: 18, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Costo del viaje',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                Text(
                  Money.mxn(_proposal!.price),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
              ],
            ),
          ] else if (trip.status != RideStatus.cancelled &&
              _loadingProposal) ...[
            const Divider(height: 18),
            SizedBox(
              height: 16,
              child: LinearProgressIndicator(
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryTripDetailScreen(
                    trip: trip,
                    proposal: _proposal,
                  ),
                ),
              ),
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: const Text('Ver detalles'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(
                    color: colorScheme.outlineVariant),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
