import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminBookingRequestsScreen extends StatelessWidget {
  const AdminBookingRequestsScreen({super.key});

  /// ✅ ACCEPT BOOKING (UPDATED 🔥)
  Future<void> acceptBooking(String id) async {
    await FirebaseFirestore.instance.collection('bookings').doc(id).update({
      'status': 'accepted',
      'approvedAt': FieldValue.serverTimestamp(), // ✅ ADDED
      'isSeen': false,
    });
  }

  /// ❌ REJECT BOOKING
  Future<void> rejectBooking(String id) async {
    await FirebaseFirestore.instance.collection('bookings').doc(id).update({
      'status': 'rejected',
      'isSeen': false,
    });
  }

  /// 👤 GET CUSTOMER NAME
  Future<String> getCustomerName(String customerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(customerId)
        .get();

    return doc.data()?['name'] ?? 'Unknown User';
  }

  /// 🚗 GET VEHICLE NUMBER
  Future<String> getVehicleNumber(String vehicleId) async {
    final doc = await FirebaseFirestore.instance
        .collection('vehicles')
        .doc(vehicleId)
        .get();

    return doc.data()?['vehicleNumber'] ?? 'Unknown Vehicle';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text("No pending bookings"));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final doc = bookings[index];
              final data = doc.data() as Map<String, dynamic>;

              final customerId = data['customerId'];
              final vehicleId = data['vehicleId'];

              /// 📅 FORMAT DATE
              String formattedDate = "No Date";
              if (data['bookingDateTime'] != null) {
                final dateTime =
                    (data['bookingDateTime'] as Timestamp).toDate();
                formattedDate =
                    DateFormat('yyyy-MM-dd – hh:mm a').format(dateTime);
              }

              return FutureBuilder<List<String>>(
                future: Future.wait([
                  getCustomerName(customerId),
                  getVehicleNumber(vehicleId),
                ]),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  final customerName = snap.data![0];
                  final vehicleNumber = snap.data![1];

                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(
                        "Service: ${data['serviceType'] ?? 'N/A'}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Customer: $customerName"),
                          Text("Vehicle: $vehicleNumber"),
                          Text("Date & Time: $formattedDate"),

                          /// 🔧 SHOW REPAIR TYPE (NEW 🔥)
                          if (data['serviceType'] == 'repair')
                            Text(
                              "Repair: ${data['repairType'] ?? ''}",
                              style: const TextStyle(color: Colors.blue),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// ✅ ACCEPT
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => acceptBooking(doc.id),
                          ),

                          /// ❌ REJECT
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => rejectBooking(doc.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
