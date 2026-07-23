import '../../../../core/network/model/models.dart';

abstract class MyTripsRepository {
  Future<List<Trip>> getMyTrips();

  /// Cancela un viaje. [reason] distingue la cancelación manual del cliente de
  /// la automática por expiración (ver [CancelReason]).
  Future<void> cancelTrip(int tripId, {int reason});
}
