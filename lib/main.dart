import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // ✅ ADD

import 'core/constants.dart';
import 'core/providers/vehicle_provider.dart'; // ✅ ADD

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/parts_screen.dart';
import 'screens/add_part_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      // ✅ ADD THIS
      providers: [ChangeNotifierProvider(create: (_) => VehicleProvider())],
      child: const DriveCareApp(),
    ),
  );
}

class DriveCareApp extends StatelessWidget {
  const DriveCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveCare+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainNavigation(),
        '/parts': (context) => const PartsScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/admin_notifications': (context) => const AdminNotificationsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/add_part': (context) => const AddPartScreen(),
      },
    );
  }
}
