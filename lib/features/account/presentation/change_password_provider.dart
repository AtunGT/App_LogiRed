import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/model/models.dart';
import '../../../core/state/view_state.dart';

class ChangePasswordProvider extends ChangeNotifier with ViewStateMixin {
  final ApiService _api;

  ChangePasswordProvider(this._api);

  String oldPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  bool success = false;

  void onOldChange(String v) {
    oldPassword = v;
    notifyListeners();
  }

  void onNewChange(String v) {
    newPassword = v;
    notifyListeners();
  }

  void onConfirmChange(String v) {
    confirmPassword = v;
    notifyListeners();
  }

  Future<void> save() async {
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      error = 'Completa todos los campos';
      notifyListeners();
      return;
    }
    if (newPassword != confirmPassword) {
      error = 'Las contraseñas nuevas no coinciden';
      notifyListeners();
      return;
    }
    if (newPassword.length < 6) {
      error = 'La contraseña debe tener al menos 6 caracteres';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && firebaseUser.email != null) {
        final credential = EmailAuthProvider.credential(
          email: firebaseUser.email!,
          password: oldPassword,
        );
        await firebaseUser.reauthenticateWithCredential(credential);
        await firebaseUser.updatePassword(newPassword);
      }

      await _api.updatePassword(
        UpdatePasswordRequest(
          oldPassword: oldPassword,
          newPassword: newPassword,
        ).toJson(),
      );

      success = true;
    } on FirebaseAuthException catch (e) {
      error = e.code == 'wrong-password' || e.code == 'invalid-credential'
          ? 'La contraseña actual es incorrecta'
          : e.message ?? 'Error al cambiar la contraseña';
    } catch (_) {
      error = 'Error al cambiar la contraseña';
    }

    isLoading = false;
    notifyListeners();
  }
}
