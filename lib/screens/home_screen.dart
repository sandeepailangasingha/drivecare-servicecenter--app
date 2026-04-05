import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../widgets/widgets.dart';
import 'my_appointments_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          final currentUser = authSnapshot.data;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentUser != null)
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                                height: 60,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: AppColors.primary)));
                          }
                          String userName = 'User';
                          if (snapshot.hasData &&
                              snapshot.data != null &&
                              snapshot.data!.exists) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            userName = data?['name'] ?? 'User';
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $userName',
                                style: const TextStyle(
                                    fontSize: 28,
                                    color: AppColors.textSecondary),
                              ),
                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        },
                      )
                    else
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Guest',
                            style: TextStyle(
                                fontSize: 28, color: AppColors.textSecondary),
                          ),
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    const SizedBox(height: 32),
                    // Main Vehicle Card
                    if (currentUser != null)
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('vehicles')
                            .where('customerId', isEqualTo: currentUser.uid)
                            .where('status', isEqualTo: 'approved')
                            .limit(1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const AppCard(
                              color: AppColors.accentBlue,
                              padding: EdgeInsets.all(24),
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white)),
                            );
                          }
                          String vehicleModel = 'No Vehicle Added';
                          String vehicleNumber = 'N/A';
                          if (snapshot.hasData &&
                              snapshot.data != null &&
                              snapshot.data!.docs.isNotEmpty) {
                            final data = snapshot.data!.docs.first.data()
                                as Map<String, dynamic>;
                            
                            final brand = data['brand']?.toString() ?? '';
                            final model = data['model']?.toString() ?? '';
                            final brandModel = '$brand $model'.trim();
                            
                            vehicleModel = brandModel.isNotEmpty
                                    ? brandModel
                                    : 'Unknown Model';
                                    
                            vehicleNumber =
                                data['vehicleNumber']?.toString().isNotEmpty ==
                                        true
                                    ? data['vehicleNumber']
                                    : 'Unknown Plate';
                          }
                          return _buildVehicleCard(vehicleModel, vehicleNumber);
                        },
                      )
                    else
                      _buildVehicleCard('No Vehicle Added', 'N/A'),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Quick Actions'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        QuickActionCard(
                          label: 'My Appointments',
                          icon: Icons.event_note_outlined,
                          iconColor: AppColors.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyAppointmentsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        QuickActionCard(
                          label: 'View History',
                          icon: Icons.assignment_outlined,
                          iconColor: AppColors.accentPurple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        StreamBuilder<DocumentSnapshot>(
                          stream: currentUser != null
                              ? FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser.uid)
                                  .snapshots()
                              : const Stream.empty(),
                          builder: (context, userSnap) {
                            final userData =
                                userSnap.data?.data() as Map<String, dynamic>?;
                            final lastRead =
                                userData?['lastReadNotificationsAt']
                                    as Timestamp?;

                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('notifications')
                                  .snapshots(),
                              builder: (context, notifSnap) {
                                int unreadCount = 0;
                                if (notifSnap.hasData) {
                                  for (var doc in notifSnap.data!.docs) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final ts = data['createdAt'] as Timestamp?;
                                    if (ts != null) {
                                      if (lastRead == null ||
                                          ts.compareTo(lastRead) > 0) {
                                        unreadCount++;
                                      }
                                    } else if (lastRead == null) {
                                      unreadCount++;
                                    }
                                  }
                                }
                                return QuickActionCard(
                                  label: 'Notifications',
                                  icon: Icons.notifications_active_outlined,
                                  iconColor: AppColors.accentGreen,
                                  unreadCount: unreadCount,
                                  onTap: () {
                                    if (currentUser != null) {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(currentUser.uid)
                                          .set({
                                        'lastReadNotificationsAt':
                                            FieldValue.serverTimestamp()
                                      }, SetOptions(merge: true));
                                    }
                                    Navigator.pushNamed(
                                        context, '/notifications');
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'Recent Activity'),
                    const SizedBox(height: 16),
                    const ActivityCard(
                      icon: Icons.check_circle_outlined,
                      iconColor: AppColors.accentGreen,
                      title: 'System Active',
                      subtitle: 'Ready to track your vehicle health.',
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildVehicleCard(String model, String number) {
    return AppCard(
      color: AppColors.accentBlue,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Vehicle',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    model,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    number,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
