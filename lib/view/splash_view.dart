import 'package:flutter/material.dart';

import '../view_modal/services/splash_services.dart';


class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  SplashServices splashServices = SplashServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SplashServices().checkUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Text(
              'Travel Planner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),)));
  }
}
