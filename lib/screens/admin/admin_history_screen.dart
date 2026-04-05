import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants.dart';

class AdminHistoryScreen extends StatefulWidget {
  final String? bookingId;
  final String? initialCustomerId;
  final String? initialCustomerEmail;
  final String? initialVehicleNumber;
  final String? initialServiceType;

  const AdminHistoryScreen({
    super.key,
    this.bookingId,
    this.initialCustomerId,
    this.initialCustomerEmail,
    this.initialVehicleNumber,
    this.initialServiceType,
  });

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _billController = TextEditingController();
  final _partsController = TextEditingController();
  final _descController = TextEditingController();
  late final TextEditingController _vehicleController;
  late final TextEditingController _serviceTypeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _vehicleController = TextEditingController(text: widget.initialVehicleNumber ?? '');
    _serviceTypeController = TextEditingController(text: widget.initialServiceType ?? '');
  }

  @override
  void dispose() {
    _billController.dispose();
    _partsController.dispose();
    _descController.dispose();
    _vehicleController.dispose();
    _serviceTypeController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final vehicleNum = _vehicleController.text.trim();
      final serviceType = _serviceTypeController.text.trim();
      String customerId = widget.initialCustomerId ?? '';
      String customerEmail = widget.initialCustomerEmail ?? 'Unknown';

      // If manual entry, find the customerId from the vehicle number
      if (customerId.isEmpty) {
        final vehicleSnap = await FirebaseFirestore.instance
            .collection('vehicles')
            .where('vehicleNumber', isEqualTo: vehicleNum)
            .limit(1)
            .get();

        if (vehicleSnap.docs.isNotEmpty) {
          customerId = vehicleSnap.docs.first.data()['customerId'] ?? '';
        } else {
          throw Exception("Vehicle Number ($vehicleNum) not found in registered vehicles.");
        }
      }

      // 1. Save data to service_history collection
      await FirebaseFirestore.instance.collection('service_history').add({
        'bookingId': widget.bookingId ?? 'Manual Entry',
        'customerId': customerId,
        'customerEmail': customerEmail,
        'vehicleNumber': vehicleNum,
        'serviceType': serviceType,
        'billAmount': double.parse(_billController.text.trim()),
        'replacedParts': _partsController.text.trim(),
        'description': _descController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Update booking status to 'Completed' if a bookingId was provided
      if (widget.bookingId != null && widget.bookingId!.isNotEmpty) {
        await FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).update({
          'status': 'Completed',
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service history added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isManual = widget.initialVehicleNumber == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isManual ? 'Update History' : 'Add Service Report', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isManual)
                // Summary Card for pre-filled booking
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vehicle: ${widget.initialVehicleNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Service: ${widget.initialServiceType}'),
                      const SizedBox(height: 4),
                      Text('Customer: ${widget.initialCustomerEmail}'),
                    ],
                  ),
                ),
                
              if (isManual) ...[
                const Text('Vehicle Number', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _vehicleController,
                  decoration: InputDecoration(
                    hintText: 'e.g. CAA-1234',
                    filled: true,
                    fillColor: AppColors.lightGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter vehicle number' : null,
                ),
                const SizedBox(height: 20),

                const Text('Service Type', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _serviceTypeController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Full Service, Oil Change',
                    filled: true,
                    fillColor: AppColors.lightGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter service type' : null,
                ),
                const SizedBox(height: 20),
              ],
              
              if (!isManual) const SizedBox(height: 24),

              // Description Field
              const Text('Service Details / Description', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the work done...',
                  filled: true,
                  fillColor: AppColors.lightGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 20),

              // Replaced Parts Field
              const Text('Replaced Parts (Optional)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _partsController,
                decoration: InputDecoration(
                  hintText: 'e.g. Engine Oil, Oil Filter, Brake Pads',
                  filled: true,
                  fillColor: AppColors.lightGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bill Amount Field
              const Text('Total Bill Amount (Rs.)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _billController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter total cost',
                  filled: true,
                  fillColor: AppColors.lightGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bill amount is required';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isManual ? 'Save History' : 'Save & Mark Completed',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
