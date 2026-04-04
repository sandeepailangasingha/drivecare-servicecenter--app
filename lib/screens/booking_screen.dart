import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final String customerId;

  const BookingScreen({super.key, required this.customerId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedVehicle;
  String? selectedVehicleNumber;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String serviceType = 'service';
  String? repairType;

  bool bookingSuccess = false;

  /// 📅 PICK DATE
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// ⏰ PICK TIME
  Future<void> pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  /// 🚀 BOOK
  Future<void> bookNow() async {
    if (selectedVehicle == null ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select all details")),
      );
      return;
    }

    if (serviceType == 'repair' && repairType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select repair type")),
      );
      return;
    }

    final bookingDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    await FirebaseFirestore.instance.collection('bookings').add({
      'customerId': widget.customerId,
      'vehicleId': selectedVehicle,
      'vehicleNumber': selectedVehicleNumber,
      'serviceType': serviceType,
      'repairType': repairType,
      'status': 'pending',
      'isSeen': false,
      'bookingDateTime': bookingDateTime,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      bookingSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Service")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: bookingSuccess
            ? _buildSuccessUI()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    /// 🚗 VEHICLE
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('vehicles')
                          .where('customerId', isEqualTo: widget.customerId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final vehicles = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          hint: const Text("Select Vehicle"),
                          value: selectedVehicle,
                          isExpanded: true,
                          onChanged: (value) {
                            final selectedDoc =
                                vehicles.firstWhere((v) => v.id == value);

                            setState(() {
                              selectedVehicle = value;
                              selectedVehicleNumber =
                                  selectedDoc['vehicleNumber'];
                            });
                          },
                          items: vehicles.map((v) {
                            return DropdownMenuItem(
                              value: v.id,
                              child: Text(v['vehicleNumber']),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    /// 🔥 SERVICE TYPE
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Select Type",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile(
                                title: const Text("Service"),
                                value: 'service',
                                groupValue: serviceType,
                                onChanged: (value) {
                                  setState(() {
                                    serviceType = value!;
                                    repairType = null;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile(
                                title: const Text("Repair"),
                                value: 'repair',
                                groupValue: serviceType,
                                onChanged: (value) {
                                  setState(() {
                                    serviceType = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    /// 🔧 BEAUTIFUL BOX REPAIR UI 🔥
                    if (serviceType == 'repair')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Select Repair Type",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _repairBox("Engine Repair"),
                              _repairBox("Oil Change"),
                              _repairBox("Brake Repair"),
                              _repairBox("Full Checkup"),
                              _repairBox("Battery Replacement"),
                              _repairBox("Tyre Replacement"),
                              _repairBox("Wheel Alignment"),
                              _repairBox("Suspension Repair"),
                              _repairBox("AC Repair"),
                              _repairBox("Electrical Repair"),
                              _repairBox("Clutch Repair"),
                              _repairBox("Transmission Repair"),
                              _repairBox("Radiator Repair"),
                              _repairBox("Fuel System Repair"),
                              _repairBox("Steering Repair"),
                              _repairBox("Exhaust Repair"),
                              _repairBox("Headlight / Wiring Fix"),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    /// 📅 DATE
                    ListTile(
                      title: Text(
                        selectedDate == null
                            ? "Select Date"
                            : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: pickDate,
                    ),

                    /// ⏰ TIME
                    ListTile(
                      title: Text(
                        selectedTime == null
                            ? "Select Time"
                            : selectedTime!.format(context),
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: pickTime,
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: bookNow,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Book Now"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// 🔥 REPAIR BOX UI
  Widget _repairBox(String type) {
    final isSelected = repairType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          repairType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
          ),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 🎉 SUCCESS UI
  Widget _buildSuccessUI() {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    final formattedTime = selectedTime!.format(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          const Text(
            "Booking Sent Successfully!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text("Vehicle: $selectedVehicleNumber"),
          Text("Date: $formattedDate"),
          Text("Time: $formattedTime"),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Back"),
          ),
        ],
      ),
    );
  }
}
