import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';
import 'trip_view_modal.dart';
import 'main_view_model.dart';

class UserViewModel extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  UserViewModel() {
    getUser(); // Load initial user data
  }

  Future<bool> saveUser(UserModel user) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('user_data', jsonEncode(user.toJson()));
    _user = user;
    notifyListeners();
    return true;
  }

  Future<UserModel> getUser() async {
    if (_user != null) return _user!;

    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? userData = sp.getString('user_data');

    if (userData == null || userData.isEmpty) {
      _user = UserModel();
      notifyListeners();
      return _user!;
    }
    _user = UserModel.fromJson(jsonDecode(userData));
    notifyListeners();
    return _user!;
  }

  Future<bool> removeUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove('user_data');
    _user = null;
    notifyListeners();
    return true;
  }

  Future<void> handleLogout(BuildContext context) async {
    // 1. Clear user data
    await removeUser();

    // 2. Clear trip data
    if (context.mounted) {
      final tripViewModel = Provider.of<TripViewModel>(context, listen: false);
      await tripViewModel.clearAllTrips();

      // 3. Reset Index to 0
      final mainViewModel = Provider.of<MainViewModel>(context, listen: false);
      mainViewModel.setSelectedIndex(0);
    }
  }
}
