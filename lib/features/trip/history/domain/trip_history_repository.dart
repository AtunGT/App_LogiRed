import '../../../../core/network/model/models.dart';

abstract class TripHistoryRepository {
  Future<List<Trip>> getClientTrips();
  Future<List<Trip>> getDriverTrips();

  /// Viajes cancelados/expirados a los que el conductor propuso pero nunca
  /// le fueron asignados (la API no los incluye en /rides/history del
  /// conductor). [excludeRideIds] evita duplicar los que ya vinieron.
  Future<List<Trip>> getExpiredProposalTrips(Set<int> excludeRideIds);
}
