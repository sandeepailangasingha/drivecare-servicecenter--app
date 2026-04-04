import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminManageBookingsScreen extends StatelessWidget {
  const AdminManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('status', isEqualTo: 'accepted') // ✅ ONLY ACCEPTED
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text("No accepted bookings"));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;

              final vehicle = data['vehicleNumber'] ?? 'Unknown';
              final customer = data['customerName'] ?? 'Unknown';
              final serviceType = data['serviceType'] ?? 'service';
              final repairType = data['repairType'];

              /// DATE
              String dateTime = "No Date";
              if (data['bookingDateTime'] != null) {
                final dt = (data['bookingDateTime'] as Timestamp).toDate();
                dateTime = DateFormat('yyyy-MM-dd – hh:mm a').format(dt);
              }

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Vehicle: $vehicle"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer: $customer"),
                      Text("Date & Time: $dateTime"),
                      Text(
                        serviceType == 'repair'
                            ? "Type: Repair (${repairType ?? ''})"
                            : "Type: Service",
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Approved ✅",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
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
