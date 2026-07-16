import 'package:flutter/material.dart';

class RoleSelectionProvider extends ChangeNotifier {
  void selectClient(BuildContext context) {
    Navigator.pushNamed(context, '/register-client');
  }

  void selectDriver(BuildContext context) {
    Navigator.pushNamed(context, '/register-driver');
  }

  void goToLogin(BuildContext context) {
    Navigator.pushNamed(context, '/login');
  }
}
