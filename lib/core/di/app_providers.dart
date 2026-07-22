import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../local/token_manager.dart';
import '../network/api_service.dart';
import '../theme/theme_provider.dart';
import '../websocket/websocket_manager.dart';
import 'service_locator.dart';
import '../../features/login/domain/repository/login_repository.dart';
import '../../features/login/data/repository/login_repository_impl.dart';
import '../../features/login/registerclient/domain/repository/register_client_repository.dart';
import '../../features/login/registerclient/data/repository/register_client_repository_impl.dart';
import '../../features/login/registerdriver/domain/repository/register_driver_repository.dart';
import '../../features/login/registerdriver/data/repository/register_driver_repository_impl.dart';
import '../../features/trip/home/domain/home_repository.dart';
import '../../features/trip/home/data/repository/home_repository_impl.dart';
import '../../features/trip/mytrips/domain/my_trips_repository.dart';
import '../../features/trip/mytrips/data/repository/my_trips_repository_impl.dart';
import '../../features/trip/available/domain/available_trips_repository.dart';
import '../../features/trip/available/data/repository/available_trips_repository_impl.dart';
import '../../features/trip/history/domain/trip_history_repository.dart';
import '../../features/trip/history/data/repository/trip_repository_impl.dart';

List<SingleChildWidget> appProviders = [
  Provider<TokenManager>(create: (_) => sl.tokenManager),
  Provider<ApiService>(create: (_) => sl.apiService),
  Provider<WebSocketManager>(create: (_) => sl.webSocketManager),
  ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),


  Provider<LoginRepository>(
    create: (c) => LoginRepositoryImpl(c.read<ApiService>(), c.read<TokenManager>()),
  ),
  Provider<RegisterClientRepository>(
    create: (c) => RegisterClientRepositoryImpl(c.read<ApiService>()),
  ),
  Provider<RegisterDriverRepository>(
    create: (c) => RegisterDriverRepositoryImpl(c.read<ApiService>()),
  ),
  Provider<HomeRepository>(
    create: (c) => HomeRepositoryImpl(c.read<ApiService>()),
  ),
  Provider<MyTripsRepository>(
    create: (c) => MyTripsRepositoryImpl(c.read<ApiService>()),
  ),
  Provider<AvailableTripsRepository>(
    create: (c) => AvailableTripsRepositoryImpl(c.read<ApiService>()),
  ),
  Provider<TripHistoryRepository>(
    create: (c) => TripHistoryRepositoryImpl(c.read<ApiService>()),
  ),
];
