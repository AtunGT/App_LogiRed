import '../../../core/di/service_locator.dart';
import '../../../core/network/model/models.dart';

Future<Proposal?> fetchAcceptedProposal(int rideId) async {
  final userType = await sl.tokenManager.getUserType() ?? 1;
  if (userType == 2) {
    final res = await sl.apiService.getMyProposals();
    final list = (res.data['proposals'] ?? res.data) as List? ?? [];
    for (final e in list) {
      final p = Proposal.fromJson(e as Map<String, dynamic>);
      if (p.idRide == rideId && p.status == 1) return p;
    }
    return null;
  }
  final res = await sl.apiService.getProposalsByRide(rideId);
  final list = (res.data['proposals'] as List? ?? [])
      .map((e) => Proposal.fromJson(e as Map<String, dynamic>))
      .toList();
  return list.where((p) => p.status == 1).firstOrNull;
}

Future<Proposal> enrichProposal(Proposal basic) async {
  var result = basic;

  try {
    final detail = await sl.apiService.getProposalById(basic.id);
    result = Proposal.fromJson(detail.data as Map<String, dynamic>);
  } catch (_) {}

  final driverId = result.idDriver ?? basic.idDriver;
  if (driverId != null && driverId != 0) {
    try {
      final res = await sl.apiService.getDriverProfile(driverId);
      final raw = res.data as Map<String, dynamic>;
      final info = (raw['driver_info'] as Map<String, dynamic>?) ?? raw;
      final carJson = info['car'] as Map<String, dynamic>?;
      final base = UserResponse.fromJson(raw);

      final driver = UserResponse(
        iduser: base.iduser,
        name: base.name,
        lastname: base.lastname,
        email: base.email,
        numberPhone: base.numberPhone,
        birthdate: base.birthdate,
        userType: base.userType,
        imageUrl: base.imageUrl,
        rating: (info['rating'] as num?)?.toDouble() ?? result.driver?.rating,
        totalTrips: result.driver?.totalTrips,
        summaryProfile: base.summaryProfile,
      );

      result = result.copyWith(
        idDriver: driverId,
        driver: driver,
        car: carJson != null ? Car.fromJson(carJson) : null,
      );
    } catch (_) {}
  }

  return result;
}
