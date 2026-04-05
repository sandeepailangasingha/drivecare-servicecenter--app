import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';

class MyAppointmentsScreen extends StatelessWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: _buildMyBookingsSection(context),
      ),
    );
  }

  Widget _buildMyBookingsSection(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in to view appointments."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('customerId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final qs = snapshot.data;
        if (qs == null || qs.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "You don't have any bookings yet.",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        // Get docs and sort them safely
        final docs = qs.docs;
        final sortedDocs = docs.toList()..sort((a, b) {
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

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedDocs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = sortedDocs[index].data() as Map<String, dynamic>;
            final serviceType = data['serviceType'] ?? 'Unknown Service';
            final status = data['status'] ?? 'Pending';
            final timeSlot = data['timeSlot'] ?? '';
            final dateTimestamp = data['date'] as Timestamp?;
            final dateStr = dateTimestamp != null 
                ? DateFormat('MMM dd').format(dateTimestamp.toDate())
                : '';

            Color statusColor;
            IconData statusIcon;

            if (status == 'Accepted') {
              statusColor = AppColors.success;
              statusIcon = Icons.check_circle;
            } else if (status == 'Declined') {
              statusColor = AppColors.error;
              statusIcon = Icons.cancel;
            } else {
              statusColor = Colors.orange;
              statusIcon = Icons.pending;
            }

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightGrey),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(statusIcon, color: statusColor),
                ),
                title: Text(
                  serviceType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$dateStr at $timeSlot'),
                    if (status == 'Declined') ...[
                      const SizedBox(height: 6),
                      Text(
                        'Reason: ${data['declineReason'] ?? 'No reason provided by Admin'}',
                        style: const TextStyle(
                          color: Colors.redAccent, 
                          fontSize: 13, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
