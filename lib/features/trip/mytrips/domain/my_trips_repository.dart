import '../../../../core/network/model/models.dart';

abstract class MyTripsRepository {
  Future<List<Trip>> getMyTrips();
  Future<void> cancelTrip(int tripId);
}
