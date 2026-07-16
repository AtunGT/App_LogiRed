import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    _Section(
      number: 1,
      title: 'Información que recopilamos',
      body:
          'Recopilamos datos personales como nombre, correo electrónico, número de teléfono, foto de perfil y ubicación durante el uso del servicio. Esta información es necesaria para operar la plataforma de forma segura.',
    ),
    _Section(
      number: 2,
      title: 'Uso de la información',
      body:
          'Usamos tu información para gestionar tu cuenta, conectar conductores con clientes, procesar pagos, enviar notificaciones del servicio y mejorar la plataforma. No vendemos tus datos a terceros.',
    ),
    _Section(
      number: 3,
      title: 'Compartir información',
      body:
          'Compartimos datos únicamente con las partes involucradas en un viaje (conductor y cliente) y con proveedores de pago autorizados. En ningún caso compartimos tu información sin tu consentimiento, salvo requerimiento legal.',
    ),
    _Section(
      number: 4,
      title: 'Seguridad de tus datos',
      body:
          'Aplicamos medidas técnicas y organizativas para proteger tu información contra acceso no autorizado, pérdida o alteración. Tus contraseñas se almacenan cifradas y nunca son visibles para nuestro equipo.',
    ),
    _Section(
      number: 5,
      title: 'Tus derechos',
      body:
          'Tienes derecho a acceder, rectificar o eliminar tus datos personales en cualquier momento. Puedes ejercer estos derechos contactándonos directamente desde la sección de Soporte en la app.',
    ),
    _Section(
      number: 6,
      title: 'Cambios en la política',
      body:
          'Podemos actualizar esta política ocasionalmente. Te notificaremos en la app con al menos 10 días de anticipación ante cambios significativos. El uso continuado del servicio implica aceptación de la política vigente.',
    ),
  ];

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
          'Política de privacidad',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_sections.length, (i) {
                final s = _sections[i];
                return Padding(
                  padding: EdgeInsets.only(top: i > 0 ? 20 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${s.number}. ${s.title}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.body,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.55,
                            ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section {
  final int number;
  final String title;
  final String body;
  const _Section(
      {required this.number, required this.title, required this.body});
}
