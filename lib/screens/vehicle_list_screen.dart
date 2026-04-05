import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../widgets/widgets.dart';
import 'add_vehicle_screen.dart';

class VehicleListScreen extends StatefulWidget {
  final String customerId;

  const VehicleListScreen({super.key, required this.customerId});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  Map<String, dynamic>? selectedVehicle;

  /// 🔷 MAIN CARD
  Widget _buildMainVehicleCard(String number, String chassis) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2D8CFF), Color(0xFF1E6FD9)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Vehicle",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(chassis, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const Icon(Icons.check, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Vehicles"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddVehicleScreen(customerId: widget.customerId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .where('customerId', isEqualTo: widget.customerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          /// 🔥 REMOVE REJECTED
          final vehicles = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] != 'rejected';
          }).toList();

          /// 🔥 ONLY APPROVED FOR SELECTION
          final approvedVehicles = vehicles.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'approved';
          }).toList();

          /// 🔥 DEFAULT SELECT FIRST
          if (selectedVehicle == null && approvedVehicles.isNotEmpty) {
            selectedVehicle =
                approvedVehicles.first.data() as Map<String, dynamic>;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// 🔷 MAIN CARD
              if (selectedVehicle != null)
                _buildMainVehicleCard(
                  selectedVehicle!['vehicleNumber'],
                  selectedVehicle!['chassisNumber'],
                ),

              const SizedBox(height: 20),

              /// 📋 LIST
              ...vehicles.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final vehicleNumber = data['vehicleNumber'];
                final chassisNumber = data['chassisNumber'];
                final status = data['status'];

                Color color = Colors.orange;
                String text = "Pending";

                if (status == "approved") {
                  color = Colors.green;
                  text = "Approved";
                }

                return GestureDetector(
                  onTap: status == "approved"
                      ? () {
                          setState(() {
                            selectedVehicle = data;
                          });
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.directions_car,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicleNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Chassis: $chassisNumber"),
                                const SizedBox(height: 5),
                                Text(text, style: TextStyle(color: color)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
