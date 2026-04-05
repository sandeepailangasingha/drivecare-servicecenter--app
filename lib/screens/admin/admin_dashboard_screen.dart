import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../widgets/widgets.dart';
import 'admin_booking_requests_screen.dart';
import 'admin_manage_bookings_screen.dart';
import 'admin_all_vehicles_screen.dart'; // ✅ NEW IMPORT
import 'admin_history_screen.dart';
import 'admin_add_vehicle_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _showTodayStats(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Today\'s Service Stats', style: TextStyle(fontWeight: FontWeight.bold)),
          content: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('bookings')
                .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return const Text('Failed to load stats');
              }
              
              final docs = snapshot.data?.docs ?? [];
              int total = docs.length;
              int accepted = 0;
              int declined = 0;
              
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'];
                if (status == 'Accepted' || status == 'Completed') {
                  accepted++;
                } else if (status == 'Declined') {
                  declined++;
                }
              }
              
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   ListTile(
                     contentPadding: EdgeInsets.zero,
                     leading: const Icon(Icons.assignment, color: Colors.blue),
                     title: const Text('Total Requests Received'),
                     trailing: Text('$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   ),
                   ListTile(
                     contentPadding: EdgeInsets.zero,
                     leading: const Icon(Icons.check_circle, color: Colors.green),
                     title: const Text('Accepted'),
                     trailing: Text('$accepted', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                   ),
                   ListTile(
                     contentPadding: EdgeInsets.zero,
                     leading: const Icon(Icons.cancel, color: Colors.red),
                     title: const Text('Declined'),
                     trailing: Text('$declined', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                   ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textPrimary),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 👋 HEADER
              const Text(
                'Welcome,',
                style: TextStyle(fontSize: 28, color: AppColors.textSecondary),
              ),
              const Text(
                'System Administrator',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 32),

              /// ⚡ QUICK ACTIONS
              Row(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('status', isEqualTo: 'Accepted')
                        .snapshots(),
                    builder: (context, snapshot) {
                      int acceptedBookingsCount = 0;
                      final qs = snapshot.data;
                      if (qs != null) {
                        acceptedBookingsCount = qs.docs.length;
                      }
                      return QuickActionCard(
                        label: 'Accepted Bookings',
                        icon: Icons.check_circle_outline,
                        iconColor: AppColors.accentBlue,
                        unreadCount: acceptedBookingsCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AdminManageBookingsScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  QuickActionCard(
                    label: 'Update History',
                    icon: Icons.history_edu,
                    iconColor: AppColors.accentGreen,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('vehicles')
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  int pendingVehiclesCount = 0;
                  final qs = snapshot.data;
                  if (qs != null) {
                    pendingVehiclesCount = qs.docs.length;
                  }
                  return Row(
                    children: [
                      /// 🚗 MANAGE VEHICLES
                      QuickActionCard(
                        label: 'Manage Vehicles',
                        icon: Icons.directions_car,
                        iconColor: AppColors.accentPurple,
                        unreadCount: pendingVehiclesCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminAllVehiclesScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 16),

                      QuickActionCard(
                        label: 'Broadcast Message',
                        icon: Icons.campaign_outlined,
                        iconColor: Colors.orange,
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin_notifications'),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),
              
              Row(
                children: [
                   QuickActionCard(
                     label: 'Add New Vehicle',
                     icon: Icons.add_circle_outline,
                     iconColor: Colors.blueAccent,
                     onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => const AdminAddVehicleScreen(),
                         ),
                       );
                     },
                   ),
                   const SizedBox(width: 16),
                   // Dummy card to keep proportions
                   const Expanded(child: SizedBox()),
                ],
              ),

              const SizedBox(height: 32),

              /// 📊 OVERVIEW
              const SectionHeader(title: 'Overview'),
              const SizedBox(height: 16),

              /// 🔥 PENDING BOOKINGS (CLICKABLE)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('status', isEqualTo: 'Pending')
                    .snapshots(),
                builder: (context, snapshot) {
                  int count = 0;

                  final qs = snapshot.data;
                  if (qs != null) {
                    count = qs.docs.length;
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdminBookingRequestsScreen(),
                        ),
                      );
                    },
                    child: ActivityCard(
                      icon: Icons.pending_actions,
                      iconColor: Colors.orange,
                      title: '$count Booking Requests',
                      subtitle: 'Needs your approval',
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              /// ✅ COMPLETED SERVICES
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('service_history')
                    .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)))
                    .snapshots(),
                builder: (context, snapshot) {
                  int completedCount = 0;
                  if (snapshot.hasData) {
                    completedCount = snapshot.data!.docs.length;
                  }
                  return ActivityCard(
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.accentGreen,
                    title: '$completedCount Services Completed',
                    subtitle: 'Today',
                    onTap: () => _showTodayStats(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
