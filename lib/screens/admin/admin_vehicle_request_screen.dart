import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminVehicleRequestsScreen extends StatelessWidget {
  const AdminVehicleRequestsScreen({super.key});

  /// ✅ APPROVE VEHICLE
  Future<void> approveVehicle(String docId) async {
    await FirebaseFirestore.instance.collection('vehicles').doc(docId).update({
      'status': 'approved',
    });
  }

  /// ❌ REJECT VEHICLE
  Future<void> rejectVehicle(String docId) async {
    await FirebaseFirestore.instance.collection('vehicles').doc(docId).update({
      'status': 'rejected',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vehicle Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .where('status', isEqualTo: 'pending') // 🔥 only pending
            .snapshots(),
        builder: (context, snapshot) {
          /// 🔄 LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ❌ ERROR
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          /// 📭 NO REQUESTS
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No pending vehicle requests",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;

              final vehicleNumber = data['vehicleNumber'] ?? 'Unknown';
              final chassisNumber = data['chassisNumber'] ?? '---';
              final customerId = data['customerId'] ?? '';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.directions_car, color: Colors.blue),
                  title: Text(
                    vehicleNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Chassis: $chassisNumber"),
                      Text(
                        "User: $customerId",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),

                  /// ✅ ACTION BUTTONS
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// APPROVE
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await approveVehicle(doc.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Vehicle Approved")),
                          );
                        },
                      ),

                      /// REJECT
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await rejectVehicle(doc.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Vehicle Rejected")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
