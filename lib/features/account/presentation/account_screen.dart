import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/theme_provider.dart';
import 'account_provider.dart';

class AccountScreen extends StatefulWidget {
  final bool isActive;
  const AccountScreen({super.key, this.isActive = true});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final AccountProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AccountProvider()..loadUser();
  }

  @override
  void didUpdateWidget(covariant AccountScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _provider.refresh();
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
      child: Consumer<AccountProvider>(
        builder: (context, provider, _) {
          final colorScheme = Theme.of(context).colorScheme;
          final isDriver = provider.user?.userType == 2;

          return Scaffold(
            backgroundColor: colorScheme.surfaceContainerLow,
            body: SafeArea(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: provider.refresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LogiRed',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 44,
                                    backgroundColor: colorScheme.primary,
                                    backgroundImage:
                                        provider.user?.imageUrl != null
                                            ? CachedNetworkImageProvider(
                                                    provider.user!.imageUrl!)
                                                as ImageProvider
                                            : null,
                                    child: provider.user?.imageUrl == null
                                        ? Text(
                                            provider.initial,
                                            style: TextStyle(
                                              color: colorScheme.onPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 32,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    provider.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    provider.email,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color:
                                                colorScheme.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _StatCell(
                                              value:
                                                  (provider.user?.totalTrips ??
                                                          0)
                                                      .toString(),
                                              label: 'Viajes',
                                            ),
                                          ),
                                          if (isDriver) ...[
                                            VerticalDivider(
                                              width: 1,
                                              color: colorScheme.outlineVariant,
                                            ),
                                            Expanded(
                                              child: _StatCell(
                                                value: provider.user?.rating !=
                                                        null
                                                    ? provider.user!.rating!
                                                        .toStringAsFixed(1)
                                                    : '—',
                                                label: 'Calificación',
                                                showStar: true,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const _SectionLabel('Apariencia'),
                            const SizedBox(height: 8),
                            const _ThemeToggle(),
                            const SizedBox(height: 16),
                            const _SectionLabel('Mi cuenta'),
                            const SizedBox(height: 8),
                            _MenuCard(
                              colorScheme: colorScheme,
                              items: [
                                _MenuItem(
                                  icon: Icons.person_outline,
                                  label: 'Datos personales',
                                  onTap: () => Navigator.pushNamed(
                                      context, '/profile/personal'),
                                ),
                                _MenuItem(
                                  icon: Icons.mail_outline,
                                  label: 'Teléfono y correo',
                                  onTap: () => Navigator.pushNamed(
                                      context, '/profile/contact'),
                                ),
                                _MenuItem(
                                  icon: Icons.lock_outline,
                                  label: 'Cambiar contraseña',
                                  onTap: () => Navigator.pushNamed(
                                      context, '/change-password'),
                                ),
                                if (isDriver)
                                  _MenuItem(
                                    icon: Icons.directions_car_outlined,
                                    label: 'Mi vehículo',
                                    onTap: () =>
                                        Navigator.pushNamed(context, '/cars'),
                                  ),
                                if (isDriver)
                                  _MenuItem(
                                    icon: Icons.history_outlined,
                                    label: 'Historial de viajes',
                                    onTap: () => Navigator.pushNamed(
                                        context, '/trip-history'),
                                  ),
                                if (!isDriver)
                                  _MenuItem(
                                    icon: Icons.account_balance_wallet_outlined,
                                    label: 'Cartera',
                                    onTap: () =>
                                        Navigator.pushNamed(context, '/wallet'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const _SectionLabel('Soporte'),
                            const SizedBox(height: 8),
                            _MenuCard(
                              colorScheme: colorScheme,
                              items: [
                                _MenuItem(
                                  icon: Icons.help_outline,
                                  label: 'Ayuda y soporte',
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/support'),
                                ),
                                _MenuItem(
                                  icon: Icons.description_outlined,
                                  label: 'Términos y condiciones',
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/terms'),
                                ),
                                _MenuItem(
                                  icon: Icons.shield_outlined,
                                  label: 'Políticas de privacidad',
                                  onTap: () => Navigator.pushNamed(
                                      context, '/privacy-policy'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () async {
                                  await provider.logout();
                                  if (context.mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRoutes.roleSelection,
                                      (route) => false,
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.logout_outlined,
                                          size: 20, color: Colors.red),
                                      const SizedBox(width: 14),
                                      Text(
                                        'Cerrar sesión',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final bool showStar;
  const _StatCell(
      {required this.value, required this.label, this.showStar = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              if (showStar) ...[
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded,
                    size: 18, color: Color(0xFFFFC107)),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  final ColorScheme colorScheme;
  const _MenuCard({required this.items, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? const Radius.circular(14) : Radius.zero,
                  bottom: isLast ? const Radius.circular(14) : Radius.zero,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 20, color: colorScheme.onSurface),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: colorScheme.onSurface),
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: 18, color: colorScheme.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 50,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = themeProvider.isDark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              size: 20,
              color:
                  isDark ? colorScheme.onSurfaceVariant : colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isDark ? 'Modo oscuro' : 'Modo claro',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colorScheme.onSurface),
              ),
            ),
            Switch(
              value: isDark,
              onChanged: (_) => themeProvider.toggle(),
              thumbIcon: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Icon(Icons.dark_mode_outlined,
                      size: 16, color: Colors.white);
                }
                return const Icon(Icons.wb_sunny_outlined,
                    size: 16, color: Colors.white);
              }),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.dark_mode_outlined,
              size: 20,
              color:
                  isDark ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
