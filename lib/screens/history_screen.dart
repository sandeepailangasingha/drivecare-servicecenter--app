import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Service History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: user == null
          ? const Center(child: Text("Please log in to view history."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('service_history')
                  .where('customerId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading history."));
                }

                final qs = snapshot.data;
                if (qs == null || qs.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No service history found.",
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  );
                }

                // Sort by createdAt descending
                final docs = qs.docs.toList()..sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>? ?? {};
                  final bData = b.data() as Map<String, dynamic>? ?? {};
                  final aDate = aData['createdAt'];
                  final bDate = bData['createdAt'];
                  DateTime aTime = DateTime.now();
                  DateTime bTime = DateTime.now();
                  if (aDate is Timestamp) aTime = aDate.toDate();
                  if (bDate is Timestamp) bTime = bDate.toDate();
                  return bTime.compareTo(aTime);
                });

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    final dateTimestamp = data['createdAt'] as Timestamp?;
                    final dateStr = dateTimestamp != null 
                        ? DateFormat('MMM dd, yyyy').format(dateTimestamp.toDate())
                        : 'Unknown Date';

                    final serviceType = data['serviceType'] ?? 'Unknown Service';
                    final vehicleNumber = data['vehicleNumber'] ?? 'Unknown Vehicle';
                    final desc = data['description'] ?? 'No description';
                    final parts = data['replacedParts'] ?? '';
                    final billAmount = data['billAmount'] ?? 0.0;

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Expanded(
                                 child: Text(
                                  serviceType,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                                 ),
                               ),
                               Text(dateStr, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.directions_car, color: AppColors.accentPurple, size: 18),
                              const SizedBox(width: 8),
                              Text(vehicleNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(desc, style: const TextStyle(height: 1.4)),
                          if (parts.toString().trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text('Replaced Parts:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(parts, style: const TextStyle(height: 1.4)),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Bill:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(
                                'Rs. ${billAmount.toString()}', 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.success),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
