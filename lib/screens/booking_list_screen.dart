import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingListScreen extends StatelessWidget {
  final String customerId;

  const BookingListScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('customerId', isEqualTo: customerId)

            /// ✅ ONLY SHOW pending + accepted
            .where('status', whereIn: ['pending', 'accepted']).snapshots(),
        builder: (context, snapshot) {
          /// 🔥 LOADING FIX
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ❌ ERROR HANDLE
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong ❌"));
          }

          /// 📭 EMPTY
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No bookings yet"));
          }

          /// 🔥 SORT (latest first)
          final bookings = snapshot.data!.docs;

          bookings.sort((a, b) {
            final aTime = (a['createdAt'] as Timestamp?)?.toDate();
            final bTime = (b['createdAt'] as Timestamp?)?.toDate();

            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final data = bookings[index].data() as Map<String, dynamic>;

              final vehicle = data['vehicleNumber'] ?? 'Unknown';
              final status = data['status'] ?? 'pending';
              final serviceType = data['serviceType'] ?? 'service';
              final repairType = data['repairType'];

              /// 📅 DATE FORMAT
              String dateTime = "No Date";
              if (data['bookingDateTime'] != null) {
                final dt = (data['bookingDateTime'] as Timestamp).toDate();
                dateTime = DateFormat('yyyy-MM-dd – hh:mm a').format(dt);
              }

              /// 🎨 STATUS STYLE
              Color color;
              String message;

              if (status == 'accepted') {
                color = Colors.green;
                message = "Appointment Confirmed ✅";
              } else {
                color = Colors.orange;
                message = "Waiting for approval ⏳";
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🚗 VEHICLE
                      Text(
                        "Vehicle: $vehicle",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// 📅 DATE
                      Text(
                        "Date & Time: $dateTime",
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 6),

                      /// 🔧 TYPE
                      Text(
                        serviceType == 'repair'
                            ? "Type: Repair (${repairType ?? ''})"
                            : "Type: Service",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 🟢 MESSAGE
                      Text(
                        message,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// STATUS BADGE
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
