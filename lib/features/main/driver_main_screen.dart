import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/scrollable_nav_rail.dart';
import '../phone_verification/presentation/phone_verification_banner.dart';
import '../phone_verification/presentation/phone_verification_provider.dart';
import '../trip/available/presentation/available_trips_screen.dart';
import '../trip/accepted/presentation/accepted_trips_screen.dart';
import '../trip/home/presentation/home_screen.dart';
import '../account/presentation/account_screen.dart';
import '../wallet/presentation/driver_wallet_screen.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  int _currentIndex = 0;
  int _proposalCount = 0;

  static const _labels = [
    'Inicio',
    'Disponibles',
    'Propuestas',
    'Cartera',
    'Perfil',
  ];

  static const _icons = [
    (Icons.home_outlined, Icons.home),
    (Icons.explore_outlined, Icons.explore),
    (Icons.assignment_outlined, Icons.assignment),
    (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet),
    (Icons.person_outline, Icons.person),
  ];

  @override
  void initState() {
    super.initState();
    _loadProposalCount();
  }

  Future<void> _loadProposalCount() async {
    try {
      final res = await sl.apiService.getMyAcceptedTrips();
      final list = (res.data['rides'] ?? res.data) as List? ?? [];
      if (mounted) setState(() => _proposalCount = list.length);
    } catch (_) {}
  }

  List<NavigationDestination> get _navDestinations =>
      List.generate(_labels.length, (i) {
        final (outlinedIcon, filledIcon) = _icons[i];
        final showBadge = i == 2 && _proposalCount > 0;
        return NavigationDestination(
          icon: showBadge
              ? Badge(
                  label: Text('$_proposalCount'),
                  child: Icon(outlinedIcon),
                )
              : Icon(outlinedIcon),
          selectedIcon: showBadge
              ? Badge(
                  label: Text('$_proposalCount'),
                  child: Icon(filledIcon),
                )
              : Icon(filledIcon),
          label: _labels[i],
        );
      });

  List<NavigationRailDestination> get _railDestinations =>
      List.generate(_labels.length, (i) {
        final (outlinedIcon, filledIcon) = _icons[i];
        final showBadge = i == 2 && _proposalCount > 0;
        return NavigationRailDestination(
          icon: showBadge
              ? Badge(
                  label: Text('$_proposalCount'),
                  child: Icon(outlinedIcon),
                )
              : Icon(outlinedIcon),
          selectedIcon: showBadge
              ? Badge(
                  label: Text('$_proposalCount'),
                  child: Icon(filledIcon),
                )
              : Icon(filledIcon),
          label: Text(_labels[i]),
        );
      });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final useRail = Responsive.useRail(context);
    final isExpanded = Responsive.isExpanded(context);

    final screens = [
      HomeScreen(onNavigate: (i) => setState(() => _currentIndex = i)),
      const AvailableTripsScreen(),
      const AcceptedTripsScreen(),
      DriverWalletScreen(isActive: _currentIndex == 3),
      AccountScreen(isActive: _currentIndex == 4),
    ];

    final body = IndexedStack(
      index: _currentIndex,
      children: screens,
    );

    return ChangeNotifierProvider(
      create: (_) => PhoneVerificationProvider()..init(),
      child: Builder(builder: (ctx) {
        if (useRail) {
          return Scaffold(
            body: Row(
              children: [
                ScrollableNavigationRail(
                  rail: NavigationRail(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (i) =>
                        setState(() => _currentIndex = i),
                    backgroundColor: colorScheme.surfaceContainerLowest,
                    indicatorColor: colorScheme.primaryContainer,
                    extended: isExpanded,
                    labelType: isExpanded
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: isExpanded
                          ? Row(children: [
                              const SizedBox(width: 12),
                              Image.asset('assets/images/logo.png', height: 28),
                              const SizedBox(width: 10),
                              Text('LogiRed',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: colorScheme.onSurface)),
                            ])
                          : Image.asset('assets/images/logo.png', height: 28),
                    ),
                    destinations: _railDestinations,
                  ),
                ),
                VerticalDivider(
                    width: 1, thickness: 1, color: colorScheme.outlineVariant),
                Expanded(
                  child: Column(
                    children: [
                      const PhoneVerificationBanner(),
                      Expanded(child: body),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Column(
            children: [
              const PhoneVerificationBanner(),
              Expanded(child: body),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            backgroundColor: colorScheme.surfaceContainerLowest,
            indicatorColor: colorScheme.primaryContainer,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: _navDestinations,
          ),
        );
      }),
    );
  }
}
