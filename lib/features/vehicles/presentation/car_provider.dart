import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/network/model/models.dart';

class CarProvider extends ChangeNotifier {
  List<Car> cars = [];
  bool isLoading = false;
  bool isSaving = false;
  String? error;

  final carRegistrationCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final maxCapacityCtrl = TextEditingController();

  String? frontImagePath;
  String? backImagePath;
  String? platesImagePath;
  String? spacesImagePath;

  Future<void> loadCars() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await sl.apiService.getMyCars();
      final list = response.data['cars'] as List? ?? [];
      cars = list.map((e) => Car.fromJson(e)).toList();
    } catch (e) {
      error = 'Error al cargar vehículos';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> pickImage(String type) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    switch (type) {
      case 'front':
        frontImagePath = picked.path;
      case 'back':
        backImagePath = picked.path;
      case 'plates':
        platesImagePath = picked.path;
      case 'spaces':
        spacesImagePath = picked.path;
    }
    notifyListeners();
  }

  Future<void> saveCar({int? carId}) async {
    isSaving = true;
    error = null;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        'car_registration': carRegistrationCtrl.text,
        'brand': brandCtrl.text,
        'model': modelCtrl.text,
        'color': colorCtrl.text,
        'max_capacity': maxCapacityCtrl.text,
        if (frontImagePath != null)
          'frontview_image': await MultipartFile.fromFile(frontImagePath!,
              filename: 'front.jpg'),
        if (backImagePath != null)
          'backview_image': await MultipartFile.fromFile(backImagePath!,
              filename: 'back.jpg'),
        if (platesImagePath != null)
          'plates_image': await MultipartFile.fromFile(platesImagePath!,
              filename: 'plates.jpg'),
        if (spacesImagePath != null)
          'space_image': await MultipartFile.fromFile(spacesImagePath!,
              filename: 'spaces.jpg'),
      });

      if (carId != null) {
        await sl.apiService.updateCar(carId, formData);
      } else {
        await sl.apiService.createCar(formData);
      }

      _clearForm();
      await loadCars();
    } catch (e) {
      error = 'Error al guardar el vehículo';
    }

    isSaving = false;
    notifyListeners();
  }

  Future<void> deleteCar(int carId) async {
    try {
      await sl.apiService.deleteCar(carId);
      cars.removeWhere((c) => c.id == carId);
      notifyListeners();
    } catch (e) {
      error = 'Error al eliminar el vehículo';
      notifyListeners();
    }
  }

  void populateForm(Car car) {
    carRegistrationCtrl.text = car.carRegistration;
    brandCtrl.text = car.brand;
    modelCtrl.text = car.model;
    colorCtrl.text = car.color;
    maxCapacityCtrl.text = car.maxCapacity.toString();
    notifyListeners();
  }

  void _clearForm() {
    carRegistrationCtrl.clear();
    brandCtrl.clear();
    modelCtrl.clear();
    colorCtrl.clear();
    maxCapacityCtrl.clear();
    frontImagePath = null;
    backImagePath = null;
    platesImagePath = null;
    spacesImagePath = null;
  }

  @override
  void dispose() {
    carRegistrationCtrl.dispose();
    brandCtrl.dispose();
    modelCtrl.dispose();
    colorCtrl.dispose();
    maxCapacityCtrl.dispose();
    super.dispose();
  }
}
