import '../../../../core/network/model/models.dart';

abstract class TripHistoryRepository {
  Future<List<Trip>> getClientTrips();
  Future<List<Trip>> getDriverTrips();
}
