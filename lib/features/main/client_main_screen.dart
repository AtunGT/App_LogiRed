import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../trip/home/domain/home_repository.dart';
import '../../core/network/api_service.dart';
import '../../core/local/token_manager.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/scrollable_nav_rail.dart';
import '../phone_verification/presentation/phone_verification_banner.dart';
import '../phone_verification/presentation/phone_verification_provider.dart';
import '../trip/home/presentation/home_provider.dart';
import '../trip/mytrips/presentation/my_trips_screen.dart';
import '../trip/history/presentation/trip_history_screen.dart';
import '../account/presentation/account_screen.dart';
import '../trip/requesttrip/presentation/request_trip_screen.dart';
import 'client_home_screen.dart';

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _currentIndex = 0;

  static const _destinations = [
    (Icons.home_outlined, Icons.home, 'Inicio'),
    (Icons.add_circle_outline, Icons.add_circle, 'Publicar'),
    (Icons.assignment_outlined, Icons.assignment, 'Mis Viajes'),
    (Icons.history_outlined, Icons.history, 'Historial'),
    (Icons.person_outline, Icons.person, 'Perfil'),
  ];

  List<NavigationDestination> get _navDestinations => _destinations
      .map((d) => NavigationDestination(
            icon: Icon(d.$1),
            selectedIcon: Icon(d.$2),
            label: d.$3,
          ))
      .toList();

  List<NavigationRailDestination> get _railDestinations => _destinations
      .map((d) => NavigationRailDestination(
            icon: Icon(d.$1),
            selectedIcon: Icon(d.$2),
            label: Text(d.$3),
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final useRail = Responsive.useRail(context);
    final isExpanded = Responsive.isExpanded(context);

    final screens = [
      ClientHomeScreen(
        onNavigate: (i) => setState(() => _currentIndex = i),
        isActive: _currentIndex == 0,
      ),
      RequestTripScreen(
        isActive: _currentIndex == 1,
        onNavigate: (i) => setState(() => _currentIndex = i),
      ),
      MyTripsScreen(isActive: _currentIndex == 2),
      TripHistoryScreen(isActive: _currentIndex == 3),
      AccountScreen(isActive: _currentIndex == 4),
    ];

    final body = IndexedStack(
      index: _currentIndex,
      children: screens,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (c) => PhoneVerificationProvider(c.read<ApiService>(), c.read<TokenManager>())..init()),
        ChangeNotifierProvider(create: (c) => HomeProvider(c.read<HomeRepository>(), c.read<TokenManager>())),
      ],
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
