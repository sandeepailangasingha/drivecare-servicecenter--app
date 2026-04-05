import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAllVehiclesScreen extends StatefulWidget {
  const AdminAllVehiclesScreen({super.key});

  @override
  State<AdminAllVehiclesScreen> createState() => _AdminAllVehiclesScreenState();
}

class _AdminAllVehiclesScreenState extends State<AdminAllVehiclesScreen> {
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  /// ✅ APPROVE
  Future<void> approveVehicle(String id) async {
    await FirebaseFirestore.instance.collection('vehicles').doc(id).update({
      'status': 'approved',
    });
  }

  /// ❌ DELETE VEHICLE
  Future<void> deleteVehicle(BuildContext context, String id) async {
    try {
      await FirebaseFirestore.instance.collection('vehicles').doc(id).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehicle deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error deleting vehicle")));
    }
  }

  /// ⚠️ CONFIRM DELETE
  void confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Vehicle"),
        content: const Text("Are you sure you want to delete this vehicle?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteVehicle(context, id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// ❌ REJECT (for pending)
  Future<void> rejectVehicle(String id) async {
    await FirebaseFirestore.instance.collection('vehicles').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vehicle Management")),
      body: Column(
        children: [
          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by Vehicle or Chassis No...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase().trim();
                });
              },
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

          /// 🔥 FILTER VALID DATA WITH SEARCH
          final allVehicles = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final isValid = data['vehicleNumber'] != null &&
                data['vehicleNumber'].toString().isNotEmpty &&
                data['chassisNumber'] != null &&
                data['chassisNumber'].toString().isNotEmpty;

            if (!isValid) return false;

            if (searchQuery.isNotEmpty) {
              final vNum = data['vehicleNumber'].toString().toLowerCase();
              final cNum = data['chassisNumber'].toString().toLowerCase();
              return vNum.contains(searchQuery) || cNum.contains(searchQuery);
            }

            return true;
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

                          /// ❌ REJECT (DELETE)
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

                      /// 🔥 DELETE BUTTON (ADMIN)
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          confirmDelete(context, doc.id);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          );
        },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
