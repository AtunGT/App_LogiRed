import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const _tokenKey = 'jwt_token';
  static const _userTypeKey = 'user_type';
  static const _cityKey = 'city_work';
  static const _userIdKey = 'user_id';
  static const _phoneVerifiedKey = 'phone_verified';
  static const _driverStatusKey = 'driver_status';
  static const _rejectReasonKey = 'reject_reason';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<int?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userTypeKey);
  }

  Future<String?> getCityWork() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cityKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<void> saveAuthData({
    required String token,
    required int userType,
    required int userId,
    String cityWork = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userTypeKey, userType);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_cityKey, cityWork);
  }

  /// Ultimo `driver_status` confirmado por la API.
  ///
  /// Se cachea para que un fallo de red al abrir la app no cambie lo que ve el
  /// conductor: sin esto, un bloqueado recuperaria el acceso al mapa con solo
  /// quedarse sin señal.
  Future<String?> getDriverStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_driverStatusKey);
  }

  Future<String?> getRejectReason() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rejectReasonKey);
  }

  Future<void> saveDriverStatus(String status, String? reason) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverStatusKey, status);
    if (reason == null || reason.isEmpty) {
      await prefs.remove(_rejectReasonKey);
    } else {
      await prefs.setString(_rejectReasonKey, reason);
    }
  }

  Future<bool> isPhoneVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_phoneVerifiedKey) ?? false;
  }

  Future<void> setPhoneVerified(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_phoneVerifiedKey, value);
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
