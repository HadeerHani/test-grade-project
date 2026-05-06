import 'package:flutter/material.dart';
import 'active_request_page.dart';
import 'home_screen.dart';
import 'account_screen.dart';
import 'welcome_screen_modified.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.backgroundWhite,
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: AppColors.primaryDarkGreen,
      unselectedItemColor: AppColors.textgrey,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primaryDarkGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
          label: 'Requests',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
      onTap: (index) {
        if (index == currentIndex) return;
        if (index == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveRequestPage()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountScreen(selectedSkills: [])));
        }
      },
    );
  }
}
