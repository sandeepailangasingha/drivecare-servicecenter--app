import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  String? _selectedServiceType;
  String? _selectedVehicleNumber;
  bool _isLoading = false;

  final List<String> _timeSlots = [
    '09:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '01:00 PM', '02:00 PM',
    '03:00 PM', '04:00 PM', '05:00 PM'
  ];

  final List<String> _serviceTypes = [
    'Full Service',
    'Oil Change',
    'Car Wash',
    'Engine Diagnostics',
    'Brake Repair',
    'Other'
  ];

  Future<void> _submitBooking() async {
    if (_selectedTimeSlot == null || _selectedServiceType == null || _selectedVehicleNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Vehicle, Date, Time, and Service Type.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Save to Firebase
      await FirebaseFirestore.instance.collection('bookings').add({
        'customerId': user.uid,
        'customerEmail': user.email,
        'vehicleNumber': _selectedVehicleNumber,
        'date': Timestamp.fromDate(_selectedDate),
        'timeSlot': _selectedTimeSlot,
        'serviceType': _selectedServiceType,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking request submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Reset form
      setState(() {
        _selectedDate = DateTime.now();
        _selectedTimeSlot = null;
        _selectedServiceType = null;
        _selectedVehicleNumber = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to book: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Book Service',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule your appointment',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Vehicle Selection Section
            _buildSectionCard(
              title: 'Select Vehicle',
              icon: Icons.directions_car,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('vehicles')
                    .where('customerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final qs = snapshot.data;
                  if (qs == null || qs.docs.isEmpty) {
                    return const Text("No vehicles found. Please add a vehicle first in the Vehicles tab.");
                  }

                  final allVehicles = qs.docs;
                  final vehicles = allVehicles.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['status'] == 'approved';
                  }).toList();

                  if (vehicles.isEmpty) {
                    return const Text("No approved vehicles found. Please wait for your vehicle to be approved.");
                  }

                  // Verify selected vehicle is still valid
                  if (_selectedVehicleNumber != null &&
                      !vehicles.any((doc) => (doc.data() as Map<String, dynamic>)['vehicleNumber'] == _selectedVehicleNumber)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedVehicleNumber = null);
                    });
                  }

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Choose your vehicle',
                      filled: true,
                      fillColor: AppColors.lightGrey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: _selectedVehicleNumber,
                    items: vehicles.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final vNum = data['vehicleNumber'] as String;
                      return DropdownMenuItem(
                        value: vNum,
                        child: Text(vNum),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedVehicleNumber = val);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Date Picker Section
            _buildSectionCard(
              title: 'Select Date',
              icon: Icons.calendar_month,
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Time Slot Section
            _buildSectionCard(
              title: 'Select Time Slot',
              icon: Icons.access_time_filled,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _timeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedTimeSlot = selected ? slot : null;
                      });
                    },
                    backgroundColor: AppColors.lightGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide.none,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Service Type Section
            _buildSectionCard(
              title: 'Select Service Type',
              icon: Icons.build_circle,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: 'Choose a service',
                  filled: true,
                  fillColor: AppColors.lightGrey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                value: _selectedServiceType,
                items: _serviceTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedServiceType = val);
                },
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),

          ],
        ),
      ),
    );
  }



  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
