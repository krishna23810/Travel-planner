import 'package:flutter/material.dart';
import 'package:travel_planner/model/user_model.dart';
import 'package:travel_planner/utils/routes/routes_name.dart';
import 'package:travel_planner/utils/utils.dart';
import 'package:travel_planner/view_modal/user_view_modal.dart';

class SplashServices {
  Future<UserModel> getUserData() => UserViewModel().getUser();

  void checkUser(BuildContext context) {
    getUserData()
        .then((value) {
          if (value.email == null) {
            Navigator.pushReplacementNamed(context, RoutesName.login);
          } else {
            Navigator.pushReplacementNamed(context, RoutesName.home);
          }
        })
        .onError((error, stackTrace) {
          Utils.flushBarErrorMessage("some error please login again", context);
          Navigator.pushReplacementNamed(context, RoutesName.login);
        });
  }
}
