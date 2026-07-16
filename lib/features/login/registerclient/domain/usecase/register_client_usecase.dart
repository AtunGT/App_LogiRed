import '../model/client_data.dart';
import '../repository/register_client_repository.dart';

class RegisterClientUseCase {
  final RegisterClientRepository repository;
  RegisterClientUseCase(this.repository);

  Future<void> call(ClientData data) {
    if (data.name.isEmpty ||
        data.lastname.isEmpty ||
        data.email.isEmpty ||
        data.numberPhone.isEmpty ||
        data.birthdate.isEmpty ||
        data.password.isEmpty) {
      throw Exception('Completa todos los campos obligatorios');
    }
    return repository.register(data);
  }
}
