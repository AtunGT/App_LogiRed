import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/network/model/models.dart';

enum PhoneVerifState { idle, sending, codeSent, verifying, verified }

class PhoneVerificationProvider extends ChangeNotifier {
  PhoneVerifState _state = PhoneVerifState.idle;
  bool _dismissed = false;
  String? _error;
  String? _verificationId;
  String _phoneNumber = '';

  PhoneVerifState get state => _state;
  bool get showBanner => _state != PhoneVerifState.verified && !_dismissed;
  bool get codeSent => _state == PhoneVerifState.codeSent;
  String? get error => _error;
  String get maskedPhone {
    if (_phoneNumber.length < 4) return _phoneNumber;
    return '****${_phoneNumber.substring(_phoneNumber.length - 4)}';
  }

  Future<void> init() async {
    final verified = await sl.tokenManager.isPhoneVerified();
    if (verified) {
      _state = PhoneVerifState.verified;
      notifyListeners();
      return;
    }
    try {
      final res = await sl.apiService.getMe();
      final user = UserResponse.fromJson(res.data);
      _phoneNumber = user.numberPhone;
    } catch (_) {}
    notifyListeners();
  }

  void dismiss() {
    _dismissed = true;
    notifyListeners();
  }

  Future<void> sendCode() async {
    if (_phoneNumber.isEmpty) {
      _error = 'No se pudo obtener tu número de teléfono';
      notifyListeners();
      return;
    }
    _state = PhoneVerifState.sending;
    _error = null;
    notifyListeners();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+52$_phoneNumber',
      verificationCompleted: (credential) async {
        await _applyCredential(credential);
      },
      verificationFailed: (e) {
        _error = 'No se pudo enviar el código. Verifica tu número.';
        _state = PhoneVerifState.idle;
        notifyListeners();
      },
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        _state = PhoneVerifState.codeSent;
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<bool> verifyCode(String code) async {
    if (_verificationId == null) return false;
    _state = PhoneVerifState.verifying;
    _error = null;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await _applyCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.code == 'invalid-verification-code'
          ? 'Código incorrecto. Intenta de nuevo.'
          : 'Error al verificar. Intenta de nuevo.';
      _state = PhoneVerifState.codeSent;
      notifyListeners();
      return false;
    }
  }

  Future<void> _applyCredential(PhoneAuthCredential credential) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    try {
      if (currentUser != null) {
        await currentUser.linkWithCredential(credential);
      } else {
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code != 'credential-already-in-use' &&
          e.code != 'provider-already-linked') {
        rethrow;
      }
    }
    await sl.tokenManager.setPhoneVerified(true);
    _state = PhoneVerifState.verified;
    notifyListeners();
  }
}
