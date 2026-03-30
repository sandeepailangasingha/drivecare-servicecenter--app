import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'home_screen.dart';
import 'store_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    Container(), // Placeholder for Team: Vehicle Management
    Container(), // Placeholder for Team: Bookings
    const StoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: 'Vehicles'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'Booking'),
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Store'),
          ],
        ),
      ),
    );
  }
}
