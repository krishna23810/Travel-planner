import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_planner/view_modal/user_view_modal.dart';
import 'package:travel_planner/view_modal/trip_view_modal.dart';
import 'package:travel_planner/utils/routes/routes_name.dart';

import 'package:travel_planner/utils/utils.dart';
import 'package:travel_planner/res/colors.dart';

import '../res/components/round_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final user = userViewModel.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = user.name;
    final email = user.email;
    final bio = user.bio;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
        
                Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        "https://images.unsplash.com/photo-1528892952291-009c663ce843?q=80&w=644&auto=format&fit=crop",
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      (name != null && name.isNotEmpty) ? name : "Not Available",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Text(
                      email ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textColorSecondary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      (bio != null && bio.isNotEmpty) ? bio : "Not Available",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textColorSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RoundButton(
                  title: 'Edit Profile',
                  width: 250,
                  onPress: () {
                    Navigator.pushNamed(context, RoutesName.profileDetails)
                        .then((value) {
                      if (value == true && context.mounted) {
                        Utils.flushBarSuccessMessage(
                          "Profile Updated Successfully",
                          context,
                        );
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 2),
                const SizedBox(height: 15),
        
                // Stats Row
                Consumer<TripViewModel>(
                  builder: (context, tripViewModel, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatItem(
                              label: "Trips",
                              value: tripViewModel.totalTrips.toString(),
                            ),
                            _StatItem(
                              label: "Places",
                              value: tripViewModel.totalPlaces.toString(),
                            ),
                            _StatItem(
                              label: "Total Days",
                              value: tripViewModel.totalTravelDays.toString(),
                            ),



                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),

                // API Settings Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, RoutesName.settings);
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.vpn_key_outlined,
                          color: AppColors.primaryColor),
                    ),
                    title: const Text(
                      'API Settings',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    tileColor: AppColors.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListTile(
                    onTap: () {
                      _showLogoutDialog(context, userViewModel);
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout, color: Colors.red),
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    tileColor: AppColors.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // App Info
                Column(
                  children: [
                    const Text(
                      "App Version 0.0.1",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textColorSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Made with ❤️ by ",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textColorSecondary,
                          ),
                        ),
                        const Text(
                          "Krishna",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserViewModel userViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? This will clear all your saved data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Now using the centralized handleLogout from userViewModel
              userViewModel.handleLogout(context).then((_) {
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RoutesName.login,
                    (route) => false,
                  );
                }
              });
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textColorSecondary,
          ),
        ),
      ],
    );
  }
}
