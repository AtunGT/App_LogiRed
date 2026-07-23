import '../model/driver_data.dart';
import '../repository/register_driver_repository.dart';

class RegisterDriverUseCase {
  final RegisterDriverRepository repository;
  RegisterDriverUseCase(this.repository);

  Future<void> call(DriverData data) {
    if (data.name.isEmpty ||
        data.lastname.isEmpty ||
        data.email.isEmpty ||
        data.phone.isEmpty ||
        data.password.isEmpty ||
        data.docIdFront.isEmpty ||
        data.docLicense.isEmpty ||
        data.brand.isEmpty ||
        data.vehicleModel.isEmpty ||
        data.year.isEmpty ||
        data.color.isEmpty ||
        data.plate.isEmpty ||
        data.maxCapacity.isEmpty ||
        data.imgVehicleFront.isEmpty ||
        data.imgVehicleBack.isEmpty ||
        data.imgVehicleLeft.isEmpty ||
        data.imgVehicleRight.isEmpty ||
        data.imgCargoSpace.isEmpty ||
        data.imgVehiclePlate.isEmpty) {
      throw Exception('Completa todos los campos obligatorios');
    }
    return repository.register(data);
  }
}
