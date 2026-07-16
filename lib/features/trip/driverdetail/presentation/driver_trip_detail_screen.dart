import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/payment_method.dart';
import 'driver_trip_detail_provider.dart';

class DriverTripDetailScreen extends StatefulWidget {
  final int tripId;
  const DriverTripDetailScreen({super.key, required this.tripId});

  @override
  State<DriverTripDetailScreen> createState() => _DriverTripDetailScreenState();
}

class _DriverTripDetailScreenState extends State<DriverTripDetailScreen> {
  final _priceCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _priceCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) => DriverTripDetailProvider()..load(widget.tripId),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Consumer<DriverTripDetailProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.proposalSent) {
              return _ProposalSentView(price: provider.price);
            }
            if (provider.trip == null) {
              return Center(
                child: Text(
                  provider.error ?? 'Error al cargar el viaje',
                  style: TextStyle(color: colorScheme.error),
                ),
              );
            }

            final trip = provider.trip!;
            return Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 20, 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: colorScheme.onSurface),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Detalles del viaje',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      _ClientTripCard(
                        initial: provider.clientInitial,
                        name: provider.clientName,
                        imageUrl: provider.clientImageUrl,
                        trip: trip,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 12),
                      _PricingSection(
                        priceCtrl: _priceCtrl,
                        provider: provider,
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 12),
                      _CommentCard(
                        commentCtrl: _commentCtrl,
                        provider: provider,
                        colorScheme: colorScheme,
                      ),
                      if (provider.error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          style:
                              TextStyle(color: colorScheme.error, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              provider.isSending ? null : provider.sendProposal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: provider.isSending
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : const Text(
                                  'Enviar',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ClientTripCard extends StatelessWidget {
  final String initial;
  final String name;
  final String? imageUrl;
  final dynamic trip;
  final ColorScheme colorScheme;

  const _ClientTripCard({
    required this.initial,
    required this.name,
    required this.imageUrl,
    required this.trip,
    required this.colorScheme,
  });

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

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                      ? CachedNetworkImageProvider(imageUrl!) as ImageProvider
                      : null,
                  child: (imageUrl == null || imageUrl!.isEmpty)
                      ? Text(
                          initial,
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
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
                _infoRow('Origen', trip.origin, colorScheme, context),
                _infoRow('Destino', trip.destination, colorScheme, context),
                if (trip.distanceKm != null)
                  _infoRow(
                      'Distancia',
                      '${trip.distanceKm!.toStringAsFixed(0)}KM',
                      colorScheme,
                      context),
                _infoRow(
                  'Peso aproximado',
                  '${trip.approxWeight % 1 == 0 ? trip.approxWeight.toInt() : trip.approxWeight}KG',
                  colorScheme,
                  context,
                ),
                _infoRow('Fecha', _formatDate(trip.date), colorScheme, context),
                _infoRow('Hora', _formatHour(trip.hour), colorScheme, context),
                _infoRow(
                    'Método de pago',
                    PaymentMethodInfo.label(trip.paymentMethod),
                    colorScheme,
                    context),
                if (trip.description != null && trip.description!.isNotEmpty)
                  _infoRow(
                      'Descripción', trip.description!, colorScheme, context),
              ],
            ),
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

class _MaxDigitsFormatter extends TextInputFormatter {
  final int maxDigits;
  const _MaxDigitsFormatter(this.maxDigits);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(',', '');
    if (digits.length > maxDigits) return oldValue;
    return newValue;
  }
}

class _PricingSection extends StatelessWidget {
  final TextEditingController priceCtrl;
  final DriverTripDetailProvider provider;
  final ColorScheme colorScheme;

  const _PricingSection({
    required this.priceCtrl,
    required this.provider,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precio del viaje',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
              ),
              Container(
                width: 120,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontSize: 15,
                      ),
                    ),
                    Flexible(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
                          const _MaxDigitsFormatter(6),
                        ],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle:
                              TextStyle(color: colorScheme.onSurfaceVariant),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          isDense: true,
                        ),
                        onChanged: provider.onPriceChange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
              height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sugerencia de precio',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
              ),
              Text(
                provider.suggestedPrice,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: provider.suggestedPrice == '—'
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final TextEditingController commentCtrl;
  final DriverTripDetailProvider provider;
  final ColorScheme colorScheme;

  const _CommentCard({
    required this.commentCtrl,
    required this.provider,
    required this.colorScheme,
  });

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
            'Comentario del viaje',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: commentCtrl,
            maxLines: 3,
            maxLength: 200,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r"[a-zA-Z0-9áéíóúÁÉÍÓÚàèìòùÀÈÌÒÙñÑüÜ,. ]"),
              ),
            ],
            onChanged: provider.onCommentChange,
            decoration: InputDecoration(
              hintText: 'Cuéntale al cliente por qué eres la mejor opción...',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
              counterStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProposalSentView extends StatelessWidget {
  final String price;
  const _ProposalSentView({required this.price});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.check, size: 44, color: colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Propuesta enviada!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'El cliente revisará tu propuesta y te notificaremos su respuesta.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text('Volver a disponibles',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
