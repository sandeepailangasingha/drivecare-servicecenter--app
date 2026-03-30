import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../widgets/widgets.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendBroadcast() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification broadcast sent successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send broadcast')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Broadcast Message', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'New Notification',
              subtitle: 'Send alerts to all registered customers via Firebase Cloud Messaging',
            ),
            const SizedBox(height: 32),
            AppTextField(
              controller: _titleController,
              label: 'Notification Title *',
              hint: 'e.g. Exclusive Weekend Offer!',
              icon: Icons.title,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _messageController,
              label: 'Message Content *',
              hint: 'Enter the details of the promotion or alert...',
              icon: Icons.message_outlined,
            ),
            const SizedBox(height: 48),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : AppButton(
                    text: 'Send Broadcast',
                    onPressed: _sendBroadcast,
                  ),
          ],
        ),
      ),
    );
  }
}
