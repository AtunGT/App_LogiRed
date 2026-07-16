import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const _tokenKey = 'jwt_token';
  static const _userTypeKey = 'user_type';
  static const _cityKey = 'city_work';
  static const _userIdKey = 'user_id';
  static const _phoneVerifiedKey = 'phone_verified';

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
