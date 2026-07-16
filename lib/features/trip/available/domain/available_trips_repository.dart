import '../../../../core/network/model/models.dart';

abstract class AvailableTripsRepository {
  Future<List<Trip>> getAvailableTrips(String city);
  Future<void> acceptTrip(int tripId);
}
