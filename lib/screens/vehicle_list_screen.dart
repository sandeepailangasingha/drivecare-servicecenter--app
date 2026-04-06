import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants.dart';
import '../widgets/widgets.dart';
import 'add_vehicle_screen.dart';

class VehicleListScreen extends StatefulWidget {
  final String customerId;

  const VehicleListScreen({super.key, required this.customerId});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  Map<String, dynamic>? selectedVehicle;
  bool _isSelling = false;

  void _showSellConfirmationDialog(BuildContext context, String vehicleId, Map<String, dynamic> vehicleData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sell Vehicle"),
        content: const Text("Are you really want to sell your vehicle?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showPasswordVerificationDialog(context, vehicleId, vehicleData);
            },
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPasswordVerificationDialog(BuildContext context, String vehicleId, Map<String, dynamic> vehicleData) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Verify Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please enter your account password to confirm listing this vehicle for sale."),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final password = passwordController.text.trim();
              if (password.isEmpty) return;

              Navigator.pop(context); // Close dialog
              _handleSellProcess(password, vehicleId, vehicleData);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSellProcess(String password, String vehicleId, Map<String, dynamic> vehicleData) async {
    setState(() => _isSelling = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) throw "User not logged in";

      // 1. Verify Password by re-authenticating
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. Fetch User Details for Seller Info
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) throw "User profile not found";
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final sellerName = userData['name'] ?? 'Unknown Seller';
      final sellerPhone = userData['phone'] ?? 'No Contact';

      // 3. Add to marketplace collection
      await FirebaseFirestore.instance.collection('vehicles_for_sale').add({
        'brand': vehicleData['brand'],
        'model': vehicleData['model'],
        'vehicleNumber': vehicleData['vehicleNumber'],
        'chassisNumber': vehicleData['chassisNumber'],
        'vehicleType': vehicleData['vehicleType'],
        'fuelType': vehicleData['fuelType'],
        'transmission': vehicleData['transmission'],
        'sellerId': user.uid,
        'sellerName': sellerName,
        'sellerPhone': sellerPhone,
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Update the original vehicle record
      await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).update({
        'isListedForSale': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vehicle successfully listed for sale!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString().contains('wrong-password') ? 'Incorrect password' : e}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSelling = false);
    }
  }

  /// 🔷 MAIN CARD
  Widget _buildMainVehicleCard(String number, String chassis) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2D8CFF), Color(0xFF1E6FD9)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Vehicle",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(chassis, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const Icon(Icons.check, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Vehicles"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddVehicleScreen(customerId: widget.customerId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .where('customerId', isEqualTo: widget.customerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          /// 🔥 REMOVE REJECTED
          final vehicles = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] != 'rejected';
          }).toList();

          /// 🔥 ONLY APPROVED FOR SELECTION
          final approvedVehicles = vehicles.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'approved';
          }).toList();

          /// 🔥 DEFAULT SELECT FIRST
          if (selectedVehicle == null && approvedVehicles.isNotEmpty) {
            selectedVehicle =
                approvedVehicles.first.data() as Map<String, dynamic>;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// 🔷 MAIN CARD
              if (selectedVehicle != null)
                _buildMainVehicleCard(
                  selectedVehicle!['vehicleNumber'],
                  selectedVehicle!['chassisNumber'],
                ),

              const SizedBox(height: 20),

              /// 📋 LIST
              ...vehicles.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final vehicleNumber = data['vehicleNumber'];
                final chassisNumber = data['chassisNumber'];
                final status = data['status'];

                Color color = Colors.orange;
                String text = "Pending";

                if (status == "approved") {
                  color = Colors.green;
                  text = "Approved";
                }

                return GestureDetector(
                  onTap: status == "approved"
                      ? () {
                          setState(() {
                            selectedVehicle = data;
                          });
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.directions_car,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicleNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Chassis: $chassisNumber"),
                                const SizedBox(height: 5),
                                Text(text, style: TextStyle(color: color)),
                              ],
                            ),
                          ),
                          if (status == "approved" && data['isListedForSale'] != true)
                            ElevatedButton(
                              onPressed: _isSelling ? null : () => _showSellConfirmationDialog(context, doc.id, data),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                minimumSize: const Size(0, 36),
                              ),
                              child: _isSelling 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text("Sell"),
                            ),
                          if (data['isListedForSale'] == true)
                            const Text(
                              "Listed",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
