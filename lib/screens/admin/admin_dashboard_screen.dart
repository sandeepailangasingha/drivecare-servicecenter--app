import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../widgets/widgets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
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
              const Text(
                'Welcome,',
                style: TextStyle(fontSize: 28, color: AppColors.textSecondary),
              ),
              const Text(
                'System Administrator',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  QuickActionCard(
                    label: 'Manage Bookings',
                    icon: Icons.calendar_month,
                    iconColor: AppColors.accentBlue,
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  QuickActionCard(
                    label: 'Update History',
                    icon: Icons.history_edu,
                    iconColor: AppColors.accentGreen,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  QuickActionCard(
                    label: 'Register Vehicle',
                    icon: Icons.directions_car,
                    iconColor: AppColors.accentPurple,
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  QuickActionCard(
                    label: 'Broadcast Message',
                    icon: Icons.campaign_outlined,
                    iconColor: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/admin_notifications'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const SectionHeader(title: 'Overview'),
              const SizedBox(height: 16),
              ActivityCard(
                icon: Icons.pending_actions,
                iconColor: Colors.orange,
                title: '5 Pending Bookings',
                subtitle: 'Requires your approval',
              ),
              const SizedBox(height: 12),
              ActivityCard(
                icon: Icons.check_circle_outline,
                iconColor: AppColors.accentGreen,
                title: '12 Services Completed',
                subtitle: 'Today',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
