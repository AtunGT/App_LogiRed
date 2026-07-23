class DriverData {
  final String name;
  final String lastname;
  final String email;
  final String phone;
  final String birthdate;
  final String password;
  final String? profileImagePath;

  final String docIdFront;
  final String docIdBack;
  final String docLicense;
  final String? docAddressProof;

  final String brand;
  final String vehicleModel;
  final String year;
  final String color;
  final String plate;
  final String maxCapacity;
  final String imgVehicleFront;
  final String imgVehicleBack;
  final String imgVehicleLeft;
  final String imgVehicleRight;
  final String imgCargoSpace;
  final String imgVehiclePlate;

  DriverData({
    required this.name,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.birthdate,
    required this.password,
    this.profileImagePath,
    required this.docIdFront,
    required this.docIdBack,
    required this.docLicense,
    this.docAddressProof,
    required this.brand,
    required this.vehicleModel,
    required this.year,
    required this.color,
    required this.plate,
    required this.maxCapacity,
    required this.imgVehicleFront,
    required this.imgVehicleBack,
    required this.imgVehicleLeft,
    required this.imgVehicleRight,
    required this.imgCargoSpace,
    required this.imgVehiclePlate,
  });
}
