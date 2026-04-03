import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBookingRequestsScreen extends StatelessWidget {
  const AdminBookingRequestsScreen({super.key});

  Future<void> approveBooking(String id) async {
    await FirebaseFirestore.instance.collection('bookings').doc(id).update({
      'status': 'approved',
    });
  }

  Future<void> rejectBooking(String id) async {
    await FirebaseFirestore.instance.collection('bookings').doc(id).update({
      'status': 'rejected',
    });
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

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['service'] ?? 'Service'),
                  subtitle: Text("User: ${data['userId']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => approveBooking(doc.id),
                      ),
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
      ),
    );
  }
}
