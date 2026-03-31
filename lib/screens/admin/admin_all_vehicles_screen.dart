import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAllVehiclesScreen extends StatelessWidget {
  const AdminAllVehiclesScreen({super.key});

  /// ✅ APPROVE
  Future<void> approveVehicle(String id) async {
    await FirebaseFirestore.instance.collection('vehicles').doc(id).update({
      'status': 'approved',
    });
  }

  /// ❌ REJECT → DELETE
  Future<void> rejectVehicle(String id) async {
    await FirebaseFirestore.instance.collection('vehicles').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vehicle Management")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vehicles').snapshots(),
        builder: (context, snapshot) {
          /// 🔄 LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ❌ ERROR
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          /// 📭 EMPTY
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No vehicles found"));
          }

          /// 🔥 FILTER VALID DATA
          final allVehicles = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['vehicleNumber'] != null &&
                data['vehicleNumber'].toString().isNotEmpty &&
                data['chassisNumber'] != null &&
                data['chassisNumber'].toString().isNotEmpty;
          }).toList();

          /// 🔥 SPLIT DATA
          final pendingVehicles = allVehicles.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'pending';
          }).toList();

          final approvedVehicles = allVehicles.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'approved';
          }).toList();

          return ListView(
            children: [
              /// ========================
              /// 🔶 PENDING REQUESTS
              /// ========================
              if (pendingVehicles.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Pending Requests",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ...pendingVehicles.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.directions_car,
                        color: Colors.orange,
                      ),
                      title: Text(
                        data['vehicleNumber'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Chassis: ${data['chassisNumber']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// ✅ APPROVE
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await approveVehicle(doc.id);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Vehicle Approved"),
                                ),
                              );
                            },
                          ),

                          /// ❌ REJECT
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              await rejectVehicle(doc.id);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Vehicle Removed"),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],

              /// ========================
              /// 🔷 APPROVED VEHICLES
              /// ========================
              if (approvedVehicles.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Approved Vehicles",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ...approvedVehicles.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.directions_car,
                        color: Colors.green,
                      ),
                      title: Text(
                        data['vehicleNumber'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Chassis: ${data['chassisNumber']}"),
                          const Text(
                            "Approved",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          );
        },
      ),
    );
  }
}
