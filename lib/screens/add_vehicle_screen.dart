import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddVehicleScreen extends StatefulWidget {
  final String customerId;

  const AddVehicleScreen({super.key, required this.customerId});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController chassisNumberController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();

  String? selectedVehicleType;
  String? selectedFuelType;
  String? selectedTransmission;

  final List<String> vehicleTypes = ['Car', 'Bike', 'Van', 'Lorry', 'Other'];
  final List<String> fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];
  final List<String> transmissionTypes = ['Manual', 'Auto'];

  bool isLoading = false;

  /// 🔥 ADD VEHICLE FUNCTION
  Future<void> addVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('vehicles').add({
        'customerId': widget.customerId,
        'vehicleNumber': vehicleNumberController.text.trim(),
        'chassisNumber': chassisNumberController.text.trim(),
        'vehicleType': selectedVehicleType,
        'brand': brandController.text.trim(),
        'model': modelController.text.trim(),
        'fuelType': selectedFuelType,
        'transmission': selectedTransmission,
        'status': 'pending', // 🔥 important
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehicle request sent successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    vehicleNumberController.dispose();
    chassisNumberController.dispose();
    brandController.dispose();
    modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Vehicle")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// 🚘 VEHICLE TYPE
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Vehicle Type",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedVehicleType,
                  items: vehicleTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedVehicleType = value),
                  validator: (value) => value == null ? "Select vehicle type" : null,
                ),
                const SizedBox(height: 15),

                /// 🏢 BRAND
                TextFormField(
                  controller: brandController,
                  decoration: const InputDecoration(
                    labelText: "Brand",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Enter brand" : null,
                ),
                const SizedBox(height: 15),

                /// 🏷️ MODEL
                TextFormField(
                  controller: modelController,
                  decoration: const InputDecoration(
                    labelText: "Model",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? "Enter model" : null,
                ),
                const SizedBox(height: 15),

                /// ⛽ FUEL TYPE
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Fuel Type",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedFuelType,
                  items: fuelTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedFuelType = value),
                  validator: (value) => value == null ? "Select fuel type" : null,
                ),
                const SizedBox(height: 15),

                /// ⚙️ TRANSMISSION
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Transmission",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedTransmission,
                  items: transmissionTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) => setState(() => selectedTransmission = value),
                  validator: (value) => value == null ? "Select transmission type" : null,
                ),
                const SizedBox(height: 15),

                /// 🚗 VEHICLE NUMBER
                TextFormField(
                  controller: vehicleNumberController,
                  decoration: const InputDecoration(
                    labelText: "Vehicle Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter vehicle number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                /// 🔧 CHASSIS NUMBER
                TextFormField(
                  controller: chassisNumberController,
                  decoration: const InputDecoration(
                    labelText: "Chassis Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter chassis number";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                /// 🚀 SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : addVehicle,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit Request"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
