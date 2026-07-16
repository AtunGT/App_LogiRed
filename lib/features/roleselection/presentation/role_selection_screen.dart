import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logired/features/roleselection/presentation/role_selection_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/responsive.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) => RoleSelectionProvider(),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: SafeArea(
          child: Consumer<RoleSelectionProvider>(
            builder: (context, provider, _) {
              final hPad = Responsive.horizontalPadding(context);
              final maxW = Responsive.maxContentWidth(context);
              final isLandscape = Responsive.isLandscape(context);

              Widget content = SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!isLandscape) const SizedBox(height: 32),
                    Image.asset(
                      'assets/images/logo.png',
                      height: isLandscape ? 56 : 80,
                    ),
                    SizedBox(height: isLandscape ? 16 : 28),
                    Text(
                      '¿Cómo quieres registrarte?',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selecciona el tipo de cuenta',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isLandscape ? 20 : 36),
                    if (isLandscape)
                      Row(
                        children: [
                          Expanded(
                            child: _RoleCard(
                              avatarLetter: 'C',
                              title: 'Conductor',
                              subtitle: 'Ofrece tus servicios de transporte',
                              onTap: () => provider.selectDriver(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _RoleCard(
                              avatarLetter: 'P',
                              title: 'Cliente',
                              subtitle: 'Solicita y rastrea tus envíos',
                              onTap: () => provider.selectClient(context),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _RoleCard(
                        avatarLetter: 'C',
                        title: 'Conductor',
                        subtitle: 'Ofrece tus servicios de transporte',
                        onTap: () => provider.selectDriver(context),
                      ),
                      const SizedBox(height: 12),
                      _RoleCard(
                        avatarLetter: 'P',
                        title: 'Cliente',
                        subtitle: 'Solicita y rastrea tus envíos',
                        onTap: () => provider.selectClient(context),
                      ),
                    ],
                    SizedBox(height: isLandscape ? 20 : 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta?  ',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                        GestureDetector(
                          onTap: () => provider.goToLogin(context),
                          child: Text(
                            'Inicia sesión',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );

              if (maxW != double.infinity) {
                content = Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: min(maxW, MediaQuery.sizeOf(context).width)),
                    child: content,
                  ),
                );
              }

              return content;
            },
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String avatarLetter;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.avatarLetter,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  avatarLetter,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
