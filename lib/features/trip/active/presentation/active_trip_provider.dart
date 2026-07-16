import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/model/models.dart';

class ActiveTripProvider extends ChangeNotifier {
  Trip? trip;
  bool isLoading = false;
  String? error;
  bool isDriver = false;
  double proposalPrice = 0;

  String personName = '';
  String personInitial = 'C';
  double? personRating;
  String? personImageUrl;

  Future<void> load(int tripId, bool isDriverMode, double price) async {
    isDriver = isDriverMode;
    proposalPrice = price;
    isLoading = true;
    notifyListeners();

    try {
      final response = await sl.apiService.getRideById(tripId);
      final data = response.data['ride'] ?? response.data;
      trip = Trip.fromJson(data);

      final profileId = isDriver ? trip!.clientId : (trip!.driverId ?? 0);
      if (profileId > 0) {
        try {
          final profileRes = await sl.apiService.getUserProfile(profileId);
          final user = UserResponse.fromJson(profileRes.data);
          personName = '${user.name} ${user.lastname}'.trim();
          personInitial =
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'C';
          personRating = user.rating;
          personImageUrl = user.imageUrl;
        } catch (_) {}
      }
    } catch (_) {
      error = 'Error al cargar el viaje';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateStatus(int status) async {
    if (trip == null) return false;
    try {
      await sl.apiService.updateRideStatus(
        trip!.id,
        UpdateStatusRequest(status: status).toJson(),
      );
      trip = Trip(
        id: trip!.id,
        origin: trip!.origin,
        destination: trip!.destination,
        city: trip!.city,
        originLat: trip!.originLat,
        originLng: trip!.originLng,
        destinationLat: trip!.destinationLat,
        destinationLng: trip!.destinationLng,
        date: trip!.date,
        hour: trip!.hour,
        approxWeight: trip!.approxWeight,
        description: trip!.description,
        status: status,
        clientId: trip!.clientId,
        driverId: trip!.driverId,
        distanceKm: trip!.distanceKm,
        createdAt: trip!.createdAt,
        paymentMethod: trip!.paymentMethod,
        paymentStatus: trip!.paymentStatus,
      );
      notifyListeners();
      return true;
    } catch (_) {
      error = 'Error al actualizar el estado';
      notifyListeners();
      return false;
    }
  }
}
