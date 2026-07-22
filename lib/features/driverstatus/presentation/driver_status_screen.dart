import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/driver_status.dart';

/// Pantalla que ve el conductor cuando no esta aprobado.
///
/// Los tres estados comparten estructura (icono, titulo, explicacion, motivo y
/// acciones) y solo cambian de contenido, asi que se resuelven en un unico
/// widget en vez de en tres pantallas casi identicas.
class DriverStatusScreen extends StatelessWidget {
  final String status;
  final String? reason;

  /// Relee `GET /users/me`. En `pending` es la accion principal; en los otros
  /// dos estados queda disponible como "pull to refresh".
  final Future<void> Function() onRefresh;

  /// Solo se usa en `rejected`.
  final VoidCallback onReapply;
  final VoidCallback onLogout;

  const DriverStatusScreen({
    super.key,
    required this.status,
    required this.reason,
    required this.onRefresh,
    required this.onReapply,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final content = _contentFor(status, colorScheme);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                // IntrinsicHeight acota la altura de la Column; sin el, los
                // Spacer de abajo estarian dentro de un scroll sin limite y
                // Expanded lanzaria en tiempo de ejecucion.
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Container(
                        width: 88,
                        height: 88,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: content.tint.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child:
                            Icon(content.icon, size: 44, color: content.tint),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        content.title,
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        content.body,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      if (reason != null && reason!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _ReasonCard(reason: reason!, tint: content.tint),
                      ],
                      const Spacer(),
                      const SizedBox(height: 24),
                      ..._actions(context, colorScheme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _actions(BuildContext context, ColorScheme colorScheme) {
    final primary = switch (status) {
      DriverStatus.rejected => _Action('Volver a enviar documentos', onReapply),
      DriverStatus.blocked => _Action(
          'Contactar a soporte tecnico',
          () => Navigator.pushNamed(context, AppRoutes.support),
        ),
      _ => _Action('Actualizar estado', onRefresh),
    };

    return [
      SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: primary.onPressed,
          style: FilledButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            primary.label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: onLogout,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.outline),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Cerrar sesion',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ];
  }

  _StatusContent _contentFor(String status, ColorScheme colorScheme) =>
      switch (status) {
        DriverStatus.rejected => _StatusContent(
            icon: Icons.assignment_late_outlined,
            tint: colorScheme.error,
            title: 'Tu solicitud fue rechazada',
            body:
                'Revisamos tus documentos y encontramos un problema. Corrige lo '
                'que se indica abajo y vuelve a enviarlos para que te evaluemos '
                'de nuevo.',
          ),
        DriverStatus.blocked => _StatusContent(
            icon: Icons.block,
            tint: colorScheme.error,
            title: 'Cuenta suspendida',
            body:
                'Tu cuenta fue bloqueada por el equipo de LogiRed. No es posible '
                'volver a enviar documentos desde la app: solo soporte tecnico '
                'puede revisar tu caso.',
          ),
        _ => _StatusContent(
            icon: Icons.hourglass_top_outlined,
            tint: colorScheme.primary,
            title: 'Estamos revisando tus documentos',
            body:
                'Recibimos tu solicitud y la esta revisando nuestro equipo. Te '
                'avisaremos por notificacion en cuanto haya una respuesta.',
          ),
      };
}

class _StatusContent {
  final IconData icon;
  final Color tint;
  final String title;
  final String body;

  const _StatusContent({
    required this.icon,
    required this.tint,
    required this.title,
    required this.body,
  });
}

class _Action {
  final String label;
  final VoidCallback onPressed;
  const _Action(this.label, this.onPressed);
}

class _ReasonCard extends StatelessWidget {
  final String reason;
  final Color tint;

  const _ReasonCard({required this.reason, required this.tint});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tint.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Motivo',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: tint, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            reason,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
