import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _faqs = [
    _Faq(
      q: '¿Cómo publico un nuevo viaje?',
      a: 'Ve a la pestaña "Publicar", completa la ruta, fecha, hora y detalles de la carga, luego toca "Publicar viaje". Los conductores disponibles te enviarán propuestas.',
    ),
    _Faq(
      q: '¿Cómo acepto la propuesta de un conductor?',
      a: 'En "Mis Viajes" verás las propuestas debajo de cada viaje publicado. Toca una propuesta para ver el detalle y luego presiona "Aceptar propuesta".',
    ),
    _Faq(
      q: '¿Cómo me contacto con el conductor?',
      a: 'Una vez aceptada la propuesta, en la pantalla de viaje en curso encontrarás el botón "Contactar conductor" que abre tu app de teléfono para llamarle.',
    ),
    _Faq(
      q: '¿Puedo cancelar un viaje publicado?',
      a: 'Puedes cancelar un viaje mientras no hayas aceptado ninguna propuesta. Cancellaciones con menos de 2 horas de anticipación pueden generar cargos.',
    ),
    _Faq(
      q: '¿Cómo califico mi experiencia?',
      a: 'Al finalizar el pago se abrirá automáticamente la pantalla de calificación. También puedes omitirla y calificar más tarde desde el historial de viajes.',
    ),
  ];

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/5255999988888');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openEmail() async {
    final uri = Uri.parse('mailto:soporte@logired.mx');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLow,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ayuda y soporte',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Preguntas frecuentes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: List.generate(_faqs.length, (i) {
                final isLast = i == _faqs.length - 1;
                return Column(
                  children: [
                    _FaqTile(faq: _faqs[i], colorScheme: colorScheme),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 16,
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
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
                  '¿Necesitas más ayuda?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nuestro equipo está disponible de lunes a sábado, 9:00 - 18:00 hrs.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _openWhatsApp,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'WhatsApp: +52 55 9999 8888',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _openEmail,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.outline),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'soporte@logired.mx',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final _Faq faq;
  final ColorScheme colorScheme;
  const _FaqTile({required this.faq, required this.colorScheme});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.faq.q,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: widget.colorScheme.onSurface),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.chevron_right,
                  size: 18,
                  color: widget.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(
                widget.faq.a,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Faq {
  final String q;
  final String a;
  const _Faq({required this.q, required this.a});
}
