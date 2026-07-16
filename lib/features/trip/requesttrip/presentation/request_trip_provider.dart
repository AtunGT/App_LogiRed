import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/model/models.dart';

class RequestTripProvider extends ChangeNotifier {
  String origin = '';
  String destination = '';
  double originLat = 0;
  double originLng = 0;
  double destinationLat = 0;
  double destinationLng = 0;
  double distanceKm = 0;
  String date = '';
  String hour = '';
  String approxWeight = '';
  String description = '';
  int paymentMethod = 1;
  bool isLoading = false;
  bool isLocating = false;
  String? error;
  bool success = false;

  void onDateChange(String v) {
    date = v;
    notifyListeners();
  }

  void onHourChange(String v) {
    hour = v;
    notifyListeners();
  }

  void onWeightChange(String v) {
    approxWeight = v;
    notifyListeners();
  }

  void onDescriptionChange(String v) {
    description = v;
    notifyListeners();
  }

  void onPaymentMethodChange(int v) {
    paymentMethod = v;
    notifyListeners();
  }

  void setOriginFromPlace(String address, double lat, double lng) {
    origin = address;
    originLat = lat;
    originLng = lng;
    notifyListeners();
  }

  void setDestinationFromPlace(String address, double lat, double lng) {
    destination = address;
    destinationLat = lat;
    destinationLng = lng;
    notifyListeners();
  }

  Future<void> getCurrentLocation(TextEditingController originCtrl) async {
    isLocating = true;
    error = null;
    notifyListeners();

    try {
      final status = await Permission.location.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        error = 'Se necesita permiso de ubicación';
        isLocating = false;
        notifyListeners();
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        error = 'Activa el GPS de tu dispositivo';
        isLocating = false;
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      originLat = position.latitude;
      originLng = position.longitude;

      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).join(', ');

        origin = address;
        originCtrl.text = address;
      }
    } catch (e) {
      error = 'No se pudo obtener la ubicación';
    }

    isLocating = false;
    notifyListeners();
  }

  Future<void> submit() async {
    if (origin.isEmpty ||
        destination.isEmpty ||
        date.isEmpty ||
        hour.isEmpty ||
        approxWeight.isEmpty) {
      error = 'Completa todos los campos obligatorios';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await sl.apiService.createTrip(TripRequest(
        origin: origin,
        originLat: originLat,
        originLng: originLng,
        destination: destination,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        distanceKm: distanceKm,
        date: date,
        hour: hour,
        approxWeight: double.tryParse(approxWeight) ?? 0,
        description: description.isEmpty ? null : description,
        paymentMethod: paymentMethod,
      ).toJson());
      success = true;
    } catch (e) {
      error = 'Error al crear el viaje';
    }

    isLoading = false;
    notifyListeners();
  }
}
