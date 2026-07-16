import '../local/token_manager.dart';
import '../network/api_service.dart';
import '../websocket/websocket_manager.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final TokenManager tokenManager;
  late final ApiService apiService;
  late final WebSocketManager webSocketManager;

  void init() {
    tokenManager = TokenManager();
    apiService = ApiService(tokenManager);
    webSocketManager = WebSocketManager();
  }
}

final sl = ServiceLocator();
