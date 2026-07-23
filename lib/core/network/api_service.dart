import 'package:dio/dio.dart';
import '../local/token_manager.dart';

class ApiService {
  static const _baseUrl = 'https://api-logired.shop/';

  late final Dio _dio;
  final TokenManager _tokenManager;

  ApiService(this._tokenManager) {
    _dio = Dio(BaseOptions(baseUrl: _baseUrl));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenManager.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<Response> login(Map<String, dynamic> data) =>
      _dio.post('auth/login', data: data);

  Future<Response> loginWithGoogle(String idToken) =>
      _dio.post('auth/google', data: {'idToken': idToken});

  Future<Response> createUser(FormData data) => _dio.post('users', data: data);

  Future<Response> getMe() => _dio.get('users/me');

  Future<Response> getUserProfile(int id) => _dio.get('users/$id');

  Future<Response> getDriverProfile(int id) =>
      _dio.get('users/profile-driver/$id');

  Future<Response> updateUser(FormData data) =>
      _dio.put('users/me', data: data);

  Future<Response> reapplyDriver(FormData data) =>
      _dio.post('users/me/reapply', data: data);

  Future<Response> requestPasswordResetCode(Map<String, dynamic> data) =>
      _dio.post('users/password-reset/request', data: data);

  Future<Response> resetPassword(Map<String, dynamic> data) =>
      _dio.put('users/password-reset', data: data);

  Future<Response> updatePassword(Map<String, dynamic> data) =>
      _dio.put('users/update-password', data: data);

  Future<Response> createTrip(Map<String, dynamic> data) =>
      _dio.post('rides', data: data);

  Future<Response> getRideById(int id) => _dio.get('rides/$id');

  Future<Response> getAvailableTrips() => _dio.get('rides/available');

  Future<Response> getMyAcceptedTrips() => _dio.get('rides/driver/me');

  Future<Response> getMyRequestedTrips() => _dio.get('rides/client/me');

  Future<Response> getTripsHistory() => _dio.get('rides/history');

  Future<Response> acceptTrip(int tripId) => _dio.put('rides/$tripId/accept');

  Future<Response> updateRideStatus(int id, Map<String, dynamic> data) =>
      _dio.put('rides/$id/status', data: data);

  Future<Response> confirmCashPayment(int id) =>
      _dio.put('rides/$id/payment/confirm');

  Future<Response> getMyCars() => _dio.get('cars');

  Future<Response> getCarById(int id) => _dio.get('cars/$id');

  Future<Response> createCar(FormData data) => _dio.post('cars', data: data);

  Future<Response> updateCar(int id, FormData data) =>
      _dio.put('cars/$id', data: data);

  Future<Response> deleteCar(int id) => _dio.delete('cars/$id');

  Future<Response> sendProposal(Map<String, dynamic> data) =>
      _dio.post('proposals', data: data);

  Future<Response> getProposalsByRide(int tripId) =>
      _dio.get('proposals/ride/$tripId');

  Future<Response> getMyProposals() => _dio.get('proposals/driver');

  Future<Response> getClientProposals() => _dio.get('proposals/client');

  Future<Response> getProposalById(int id) => _dio.get('proposals/$id');

  Future<Response> updateProposalStatus(int id, Map<String, dynamic> data) =>
      _dio.put('proposals/$id/accept', data: data);

  Future<Response> registerDeviceToken(Map<String, dynamic> data) =>
      _dio.put('devices/token', data: data);

  Future<Response> createPaymentIntent(Map<String, dynamic> data) =>
      _dio.post('payments/create-intent', data: data);

  Future<Response> getDriverWallet() => _dio.get('wallet/driver');

  Future<Response> getDriverWalletTransactions(
          {String? from, String? to, int page = 1, int limit = 20}) =>
      _dio.get('wallet/driver/transactions', queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        'page': page,
        'limit': limit,
      });

  Future<Response> getDriverWalletSummary(
          {String period = 'day', String? from, String? to}) =>
      _dio.get('wallet/driver/summary', queryParameters: {
        'period': period,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      });

  Future<Response> createReview(Map<String, dynamic> data) =>
      _dio.post('reviews', data: data);
}
