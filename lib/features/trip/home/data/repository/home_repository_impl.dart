import '../../../../../core/di/service_locator.dart';
import '../../../../../core/network/model/models.dart';
import '../../domain/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<List<Trip>> getClientTrips() async {
    final response = await sl.apiService.getMyRequestedTrips();
    final list = response.data['rides'] as List? ?? [];
    return list.map((e) => Trip.fromJson(e)).toList();
  }

  @override
  Future<List<Trip>> getDriverTrips() async {
    final response = await sl.apiService.getMyAcceptedTrips();
    final list = response.data['rides'] as List? ?? [];
    return list.map((e) => Trip.fromJson(e)).toList();
  }
}
