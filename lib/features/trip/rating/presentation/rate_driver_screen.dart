import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/responsive.dart';
import 'rate_driver_provider.dart';

class RateDriverScreen extends StatefulWidget {
  final int tripId;
  final int driverId;
  final String driverName;
  final String origin;
  final String destination;
  final String date;
  final String duration;

  const RateDriverScreen({
    super.key,
    required this.tripId,
    required this.driverId,
    required this.driverName,
    required this.origin,
    required this.destination,
    required this.date,
    required this.duration,
  });

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RateDriverProvider(),
      child: Consumer<RateDriverProvider>(
        builder: (context, provider, _) {
          final colorScheme = Theme.of(context).colorScheme;

          if (provider.sent) {
            return _SentView(colorScheme: colorScheme);
          }

          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLow,
            appBar: AppBar(
              backgroundColor: colorScheme.surfaceContainerLow,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                'Calificar al conductor',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              centerTitle: true,
            ),
            body: LayoutBuilder(builder: (ctx, constraints) {
              final maxW = Responsive.maxContentWidth(ctx);
              final hPad = Responsive.horizontalPadding(ctx);
              final w = min(maxW, constraints.maxWidth);
              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: w,
                  height: constraints.maxHeight,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CompletedBanner(
                          origin: widget.origin,
                          destination: widget.destination,
                          date: widget.date,
                          duration: widget.duration,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 16),
                        _DriverCard(
                          name: widget.driverName,
                          colorScheme: colorScheme,
                          provider: provider,
                        ),
                        const SizedBox(height: 16),
                        _CommentCard(
                          ctrl: _commentCtrl,
                          provider: provider,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: 16),
                        _TagsRow(provider: provider, colorScheme: colorScheme),
                        if (provider.error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            provider.error!,
                            style: TextStyle(
                                color: colorScheme.error, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: provider.isSending
                                ? null
                                : () => provider.send(widget.driverId),
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
                                    'Enviar calificación',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.clientMain,
                            (route) => false,
                          ),
                          child: Text(
                            'Omitir por ahora',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  final String origin;
  final String destination;
  final String date;
  final String duration;
  final ColorScheme colorScheme;

  const _CompletedBanner({
    required this.origin,
    required this.destination,
    required this.date,
    required this.duration,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: colorScheme.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                '¡Tu viaje ha finalizado!',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$origin → $destination',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(width: 16),
              Text(
                'Duración: $duration',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final String name;
  final ColorScheme colorScheme;
  final RateDriverProvider provider;

  const _DriverCard({
    required this.name,
    required this.colorScheme,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primary,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.verified,
                          size: 13, color: colorScheme.primary),
                      const SizedBox(width: 3),
                      Text(
                        'Conductor verificado',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '¿Cómo fue tu experiencia?',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < provider.stars;
              return GestureDetector(
                onTap: () => provider.setStars(i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 40,
                    color: filled
                        ? const Color(0xFFFFC107)
                        : colorScheme.outlineVariant,
                  ),
                ),
              );
            }),
          ),
          if (provider.starLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              provider.starLabel,
              style: const TextStyle(
                color: Color(0xFFFFC107),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final TextEditingController ctrl;
  final RateDriverProvider provider;
  final ColorScheme colorScheme;

  const _CommentCard({
    required this.ctrl,
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
            'Agrega un comentario (opcional)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: ctrl,
            maxLines: 3,
            onChanged: provider.onCommentChange,
            decoration: InputDecoration(
              hintText:
                  'Cuéntanos cómo fue el servicio con ${ctrl.text.isNotEmpty ? "" : "el conductor"}...',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagsRow extends StatelessWidget {
  final RateDriverProvider provider;
  final ColorScheme colorScheme;

  const _TagsRow({required this.provider, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: RateDriverProvider.tags.map((tag) {
        final selected = provider.selectedTags.contains(tag);
        return GestureDetector(
          onTap: () => provider.toggleTag(tag),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    selected ? colorScheme.primary : colorScheme.outlineVariant,
              ),
            ),
            child: Text(
              tag,
              style: TextStyle(
                color: selected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SentView extends StatelessWidget {
  final ColorScheme colorScheme;
  const _SentView({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.star_rounded,
                    size: 44, color: colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Gracias por tu calificación!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tu opinión ayuda a mejorar la comunidad de conductores.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.clientMain,
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('Volver al inicio',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
