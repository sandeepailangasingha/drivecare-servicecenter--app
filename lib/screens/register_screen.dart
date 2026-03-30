import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../widgets/widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Create user in Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      final uid = userCredential.user!.uid;

      // 2. Save user profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Navigate to Main Navigation
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Registration failed', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join DriveCare+ to manage your vehicles',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _nameController,
                label: 'Full Name *',
                hint: 'Enter your name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _emailController,
                label: 'Email *',
                hint: 'Enter your email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number *',
                hint: 'Enter your phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _passwordController,
                label: 'Password *',
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 48),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : AppButton(
                      text: 'Register',
                      onPressed: _register,
                    ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
