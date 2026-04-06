import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
            _VehiclesTab(),
            PartsScreen(),
          ],
        ),
      ),
    );
  }
}

class _VehiclesTab extends StatelessWidget {
  const _VehiclesTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vehicles_for_sale')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Vehicles For Sale',
                  style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            
            final brand = data['brand'] ?? 'Unknown';
            final model = data['model'] ?? 'Unknown';
            final sellerName = data['sellerName'] ?? 'Unknown';
            final sellerPhone = data['sellerPhone'] ?? 'Contact Not Available';
            final fuelType = data['fuelType'] ?? 'N/A';
            final transmission = data['transmission'] ?? 'N/A';
            final createdAt = data['createdAt'] as Timestamp?;
            final dateStr = createdAt != null 
                ? DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt.toDate())
                : '';

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.directions_car, color: AppColors.primary, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$brand $model',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (dateStr.isNotEmpty)
                                    Text(
                                      dateStr,
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _infoChip(fuelType),
                                  const SizedBox(width: 8),
                                  _infoChip(transmission),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seller',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            Text(
                              sellerName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.phone, color: AppColors.accentGreen, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                sellerPhone,
                                style: const TextStyle(
                                  color: AppColors.accentGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
