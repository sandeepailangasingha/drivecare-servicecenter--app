import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../widgets/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading notifications'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No notifications yet.', style: TextStyle(color: AppColors.textSecondary)),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24.0),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return NotificationCard(
                title: data['title'] ?? 'New Notification',
                message: data['message'] ?? '',
                icon: Icons.campaign_outlined,
                themeColor: AppColors.primary,
              );
            },
          );
        },
      ),
    );
  }
}
