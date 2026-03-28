import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travel_planner/res/colors.dart';

import 'package:travel_planner/view_modal/settings_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _weatherController = TextEditingController();
  final TextEditingController _tripMapController = TextEditingController();

  @override
  void dispose() {
    _weatherController.dispose();
    _tripMapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);
    _weatherController.text = settingsViewModel.openWeatherKey;
    _tripMapController.text = settingsViewModel.openTripMapKey;
  }

  @override
  Widget build(BuildContext context) {
    final settingsViewModel = Provider.of<SettingsViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'API Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom API Keys',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your own API keys to override the default ones. Leave blank to use defaults.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textColorSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _buildKeyField(
              title: 'OpenWeather API Key',
              controller: _weatherController,
              hint: 'Enter OpenWeatherMap API Key',
              icon: Icons.cloud_outlined,
              url: 'https://home.openweathermap.org/',
            ),
            const SizedBox(height: 20),
            _buildKeyField(
              title: 'OpenTripMap API Key',
              controller: _tripMapController,
              hint: 'Enter OpenTripMap API Key',
              icon: Icons.map_outlined,
              url: 'https://dev.opentripmap.org/',
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await settingsViewModel
                      .saveOpenWeatherKey(_weatherController.text.trim());
                  await settingsViewModel
                      .saveOpenTripMapKey(_tripMapController.text.trim());

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings saved successfully!'),
                        backgroundColor: AppColors.accentColor,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () async {
                  await settingsViewModel.clearKeys();
                  _weatherController.clear();
                  _tripMapController.clear();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Custom keys cleared.'),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Clear Custom Keys',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyField({
    required String title,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String url,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final Uri uri = Uri.parse(url);
                if (!await launchUrl(uri)) {
                  throw Exception('Could not launch $url');
                }
              },
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text(
                'Get Key',
                style: TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textColorSecondary),
              prefixIcon: Icon(icon, color: AppColors.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
