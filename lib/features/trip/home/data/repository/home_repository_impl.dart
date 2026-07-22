import '../../../../../core/network/api_service.dart';
import '../../../../../core/network/model/models.dart';
import '../../domain/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiService _api;

  HomeRepositoryImpl(this._api);

  @override
  Future<List<Trip>> getClientTrips() async {
    final response = await _api.getMyRequestedTrips();
    final list = response.data['rides'] as List? ?? [];
    return list.map((e) => Trip.fromJson(e)).toList();
  }

  @override
  Future<List<Trip>> getDriverTrips() async {
    final response = await _api.getMyAcceptedTrips();
    final list = response.data['rides'] as List? ?? [];
    return list.map((e) => Trip.fromJson(e)).toList();
  }
}
