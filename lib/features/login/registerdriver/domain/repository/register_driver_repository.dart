import '../model/driver_data.dart';

abstract class RegisterDriverRepository {
  Future<void> register(DriverData data);
}
