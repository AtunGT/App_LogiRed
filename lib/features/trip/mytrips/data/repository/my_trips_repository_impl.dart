import '../../../../../core/network/api_service.dart';
import '../../../../../core/network/model/models.dart';
import '../../../../../core/utils/ride_status.dart';
import '../../domain/my_trips_repository.dart';

class MyTripsRepositoryImpl implements MyTripsRepository {
  final ApiService _api;

  MyTripsRepositoryImpl(this._api);

  @override
  Future<List<Trip>> getMyTrips() async {
    final response = await _api.getMyRequestedTrips();
    final list = response.data['rides'] as List? ?? [];
    return list.map((e) => Trip.fromJson(e)).toList();
  }

  @override
  Future<void> cancelTrip(int tripId, {int reason = CancelReason.manual}) async {
    await _api.updateRideStatus(tripId, {
      'status': RideStatus.cancelled,
      'cancel_reason': reason,
    });
  }
}
