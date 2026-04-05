import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';

class AdminBookingRequestsScreen extends StatelessWidget {
  const AdminBookingRequestsScreen({super.key});

  Future<void> _updateBookingStatus(BuildContext context, String id, String status, [String? reason]) async {
    try {
      final updateData = <String, dynamic>{'status': status};
      if (reason != null && reason.isNotEmpty) {
        updateData['declineReason'] = reason;
      }
      
      await FirebaseFirestore.instance.collection('bookings').doc(id).update(updateData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking $status successfully.'),
            backgroundColor: status == 'Accepted' ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDeclineDialog(BuildContext context, String docId) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for declining this request:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Fully booked, Parts unavailable...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              Navigator.pop(context);
              _updateBookingStatus(context, docId, 'Declined', reason);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm Decline'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Booking Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final qs = snapshot.data;
          if (qs == null) {
            return const Center(child: Text("Data is strictly null"));
          }

          if (qs.docs.isEmpty) {
            return const Center(
              child: Text(
                "No pending bookings.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = qs.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              Map<String, dynamic> data = {};
              try {
                // Safely cast data
                final docData = doc.data();
                if (docData != null && docData is Map) {
                  data = Map<String, dynamic>.from(docData);
                }
              } catch (_) {}

              final customerEmail = data['customerEmail']?.toString() ?? 'Unknown User';
              final serviceType = data['serviceType']?.toString() ?? 'Unknown Service';
              final timeSlot = data['timeSlot']?.toString() ?? 'No Time specified';
              final vehicleNumber = data['vehicleNumber']?.toString() ?? 'Not selected';
              
              // Extreme safe date parsing to avoid any internal lib bugs
              String dateStr = 'Date Format Error';
              try {
                 final dateRaw = data['date'];
                 if (dateRaw != null) {
                   if (dateRaw is Timestamp) {
                     dateStr = DateFormat('MMM dd, yyyy').format(dateRaw.toDate());
                   } else if (dateRaw is String) {
                     dateStr = dateRaw;
                   }
                 } else {
                   dateStr = 'No Date set';
                 }
              } catch (_) {
                 dateStr = 'Date Error';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          serviceType,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vehicle: $vehicleNumber'),
                              const SizedBox(height: 4),
                              Text('User: $customerEmail'),
                              const SizedBox(height: 4),
                              Text('Date: $dateStr • $timeSlot'),
                            ],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Pending', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _showDeclineDialog(context, doc.id),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Decline'),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _updateBookingStatus(context, doc.id, 'Accepted'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Accept',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
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
