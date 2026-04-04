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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Vehicle")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
    );
  }
}
