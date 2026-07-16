import '../../../../core/network/model/models.dart';

abstract class DashboardRepository {
  Future<List<Trip>> getClientTrips();
  Future<List<Trip>> getDriverTrips();
}
