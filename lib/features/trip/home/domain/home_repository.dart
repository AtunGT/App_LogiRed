import '../../../../core/network/model/models.dart';

abstract class HomeRepository {
  Future<List<Trip>> getClientTrips();
  Future<List<Trip>> getDriverTrips();
}
