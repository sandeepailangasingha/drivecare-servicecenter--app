import 'package:flutter/material.dart';

class VehicleProvider extends ChangeNotifier {
  Map<String, dynamic>? _selectedVehicle;

  Map<String, dynamic>? get selectedVehicle => _selectedVehicle;

  void setVehicle(Map<String, dynamic> vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }
}
