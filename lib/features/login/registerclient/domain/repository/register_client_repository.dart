import '../model/client_data.dart';

abstract class RegisterClientRepository {
  Future<void> register(ClientData data);
}
