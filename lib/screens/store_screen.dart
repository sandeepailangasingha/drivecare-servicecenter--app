import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'parts_screen.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Store', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Vehicles'),
              Tab(text: 'Spare Parts'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Vehicles Store Coming Soon', style: TextStyle(color: Colors.grey))),
            PartsScreen(),
          ],
        ),
      ),
    );
  }
}
