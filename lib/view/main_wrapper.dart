import 'package:flutter/material.dart';
import 'package:travel_planner/view/home_screen.dart';
import 'package:travel_planner/view/discover_screen.dart';
import 'package:travel_planner/view/profile_screen.dart';
import 'package:travel_planner/view/trip_list_screen.dart';
import 'package:travel_planner/res/colors.dart';
import 'package:provider/provider.dart';
import 'package:travel_planner/view_modal/main_view_model.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const DiscoverScreen(),
    const TripListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final mainViewModel = Provider.of<MainViewModel>(context);

    return PopScope(
      canPop: mainViewModel.selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (mainViewModel.selectedIndex != 0) {
          mainViewModel.setSelectedIndex(0);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: IndexedStack(index: mainViewModel.selectedIndex, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: mainViewModel.selectedIndex,
          onTap: (index) => mainViewModel.setSelectedIndex(index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.textColorSecondary,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: "My Trips",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
