import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../widgets/widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdminLogin = false;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      final uid = userCredential.user!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final role = doc.data()?['role'];
        
        if (_isAdminLogin && role != 'admin') {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Access denied: Admins only', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
            );
          }
        } else if (!_isAdminLogin && role == 'admin') {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please use the Service Center Login portal', style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange),
            );
          }
        } else {
          if (mounted) {
            if (role == 'admin') {
              Navigator.pushReplacementNamed(context, '/admin_dashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/main');
            }
          }
        }
      } else {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User profile not found')));
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? 'Login failed', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Center(
                child: Icon(Icons.directions_car, size: 80, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'DriveCare+',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                _isAdminLogin ? 'Admin Portal' : 'Welcome Back!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _isAdminLogin ? 'Log in to manage the service center' : 'Log in to your account',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : AppButton(
                      text: _isAdminLogin ? 'Login as Admin' : 'Login',
                      onPressed: _login,
                    ),
              if (!_isAdminLogin) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isAdminLogin = !_isAdminLogin;
                    });
                  },
                  child: Text(
                    _isAdminLogin ? 'Switch to Customer Login' : 'Service Center Login',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
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
