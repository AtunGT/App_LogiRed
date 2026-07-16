import '../../../../core/network/model/models.dart';

abstract class AcceptedTripsRepository {
  Future<List<Trip>> getAcceptedTrips();
}
