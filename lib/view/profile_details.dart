import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_planner/model/user_model.dart';
import 'package:travel_planner/view_modal/user_view_modal.dart';
import 'package:travel_planner/res/components/round_button.dart';
import 'package:travel_planner/res/colors.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    userViewModel.getUser().then((user) {
      if (mounted) {
        setState(() {
          _nameController.text = user.name ?? '';
          _dobController.text = user.dob ?? '';
          _bioController.text = user.bio ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Edit Account Details',
          style: TextStyle(
            color: AppColors.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blackColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _EditableField(
                controller: _nameController,
                label: "Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 15),
              _EditableField(
                controller: _dobController,
                label: "Date of Birth",
                icon: Icons.calendar_today_outlined,
                hint: "DD/MM/YYYY",
              ),
              const SizedBox(height: 15),
              _EditableField(
                controller: _bioController,
                label: "User Bio",
                icon: Icons.person_2_outlined,
                hint: "Tell us about yourself",
              ),
              const SizedBox(height: 40),
              RoundButton(
                title: "Save Changes",
                width: 250,
                onPress: () async {
                  final currentUser = await userViewModel.getUser();
                  final updatedUser = UserModel(
                    email: currentUser.email,
                    name: _nameController.text,
                    dob: _dobController.text,
                    bio: _bioController.text,
                  );

                  userViewModel.saveUser(updatedUser).then((value) {
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  const _EditableField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textColorSecondary, size: 20),
        filled: true,
        fillColor: AppColors.whiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
