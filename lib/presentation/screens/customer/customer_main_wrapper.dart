import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'customer_home_screen.dart';
import 'ai_assistant_screen.dart';
import 'customer_bookings_screen.dart';
import 'skin_profile_screen.dart';

class CustomerMainWrapper extends StatefulWidget {
  const CustomerMainWrapper({super.key});

  @override
  State<CustomerMainWrapper> createState() => _CustomerMainWrapperState();
}

class _CustomerMainWrapperState extends State<CustomerMainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CustomerHomeScreen(),
    const AIAssistantScreen(),
    const CustomerBookingsScreen(),
    const SkinProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed extendBody: true because it was causing content to hide behind the nav bar
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 8, 24, 16), // Balanced margin
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.98),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepMagenta.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Explore'),
                _buildNavItem(1, Icons.auto_awesome_rounded, 'GlamBot'),
                _buildNavItem(2, Icons.calendar_today_rounded, 'Bookings'),
                _buildNavItem(3, Icons.face_retouching_natural_rounded, 'Skin'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppColors.vibrantPink : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.vibrantPink.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
