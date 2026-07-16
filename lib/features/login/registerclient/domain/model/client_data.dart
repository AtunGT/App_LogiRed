class ClientData {
  final String name;
  final String lastname;
  final String email;
  final String numberPhone;
  final String birthdate;
  final String password;
  final String? imagePath;

  ClientData({
    required this.name,
    required this.lastname,
    required this.email,
    required this.numberPhone,
    required this.birthdate,
    required this.password,
    this.imagePath,
  });
}
