import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../widgets/widgets.dart';

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});

  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Engine', 'Brakes', 'Electrical', 'Suspension'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: _categories.map((category) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: _buildCategoryChip(category, isSelected: _selectedCategory == category),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: SectionHeader(title: 'Available Parts', subtitle: 'Browse quality items from verified sellers'),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('parts').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading parts'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                final allDocs = snapshot.data?.docs ?? [];
                
                final docs = _selectedCategory == 'All'
                    ? allDocs
                    : allDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['category'] == _selectedCategory;
                      }).toList();
                
                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No parts available yet. Be the first to sell!', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(24.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    return AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.settings_suggest, size: 48, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            data['name'] ?? 'Unknown Part',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs. ${data['price'] ?? '0'}',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.storefront, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  data['sellerName'] ?? 'Anonymous Seller',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: 'Contact Seller',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        title: const Text('Seller Details', style: TextStyle(fontWeight: FontWeight.bold)),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.person, color: AppColors.primary, size: 20),
                                                const SizedBox(width: 12),
                                                Text(data['sellerName'] ?? 'Anonymous', style: const TextStyle(fontSize: 16)),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              children: [
                                                const Icon(Icons.phone, color: AppColors.primary, size: 20),
                                                const SizedBox(width: 12),
                                                Text(data['sellerPhone'] ?? 'Not available', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Close', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add_part'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('Sell Your Part', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
