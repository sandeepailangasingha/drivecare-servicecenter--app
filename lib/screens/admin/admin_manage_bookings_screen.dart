import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';

class AdminManageBookingsScreen extends StatelessWidget {
  const AdminManageBookingsScreen({super.key});

  Future<void> _updateBookingStatus(BuildContext context, String id, String status) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(id).update({
        'status': status,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking marked as $status.'),
            backgroundColor: AppColors.success,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Accepted Bookings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('status', isEqualTo: 'Accepted')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final qs = snapshot.data;
          if (qs == null || qs.docs.isEmpty) {
            return const Center(
              child: Text(
                "No accepted bookings found.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            );
          }

          final docs = qs.docs;
          final bookings = docs.toList()..sort((a, b) {
            try {
              final aData = a.data() as Map<String, dynamic>? ?? {};
              final bData = b.data() as Map<String, dynamic>? ?? {};
              
              final aDate = aData['createdAt'];
              final bDate = bData['createdAt'];
              
              DateTime aTime = DateTime.now();
              DateTime bTime = DateTime.now();
              
              if (aDate is Timestamp) aTime = aDate.toDate();
              if (bDate is Timestamp) bTime = bDate.toDate();
              
              return bTime.compareTo(aTime);
            } catch (e) {
              return 0;
            }
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final doc = bookings[index];
              final data = doc.data() as Map<String, dynamic>? ?? {};

              final customerEmail = data['customerEmail'] ?? 'Unknown User';
              final serviceType = data['serviceType'] ?? 'Unknown Service';
              final timeSlot = data['timeSlot'] ?? 'No Time specified';
              final vehicleNumber = data['vehicleNumber'] ?? 'Not selected';
              
              final dateRaw = data['date'];
              String dateStr = 'No Date';
              if (dateRaw is Timestamp) {
                dateStr = DateFormat('MMM dd, yyyy').format(dateRaw.toDate());
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              serviceType,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Accepted',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: AppColors.grey),
                          const SizedBox(width: 8),
                          Text(customerEmail),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.directions_car, size: 16, color: AppColors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Vehicle: $vehicleNumber',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: AppColors.grey),
                          const SizedBox(width: 8),
                          Text('$dateStr • $timeSlot'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.success,
                              side: const BorderSide(color: AppColors.success),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle_outline, size: 20),
                            onPressed: () => _updateBookingStatus(context, doc.id, 'Completed'),
                            label: const Text('Mark Completed'),
                          ),
                        ],
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
