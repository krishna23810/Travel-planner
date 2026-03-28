import 'package:travel_planner/utils/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:travel_planner/view/login_screen.dart';
import 'package:travel_planner/view/profile_details.dart';
import 'package:travel_planner/view/discover_screen.dart';
import 'package:travel_planner/view/main_wrapper.dart';
import 'package:travel_planner/view/profile_screen.dart';
import 'package:travel_planner/view/splash_view.dart';
import 'package:travel_planner/view/place_details_screen.dart';
import 'package:travel_planner/view/trip_list_screen.dart';
import 'package:travel_planner/view/settings_screen.dart';
import 'package:travel_planner/model/place_model.dart';



class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.splash:
        return MaterialPageRoute(
          builder: (BuildContext context) => const SplashView(),
        );

      case RoutesName.login:
        return MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen(),
        );

      case RoutesName.home:
        return MaterialPageRoute(
          builder: (BuildContext context) => const MainWrapper(),
        );

      case RoutesName.profile:
        return MaterialPageRoute(
          builder: (BuildContext context) => const ProfileScreen(),
        );

      case RoutesName.profileDetails:
        return MaterialPageRoute(
          builder: (BuildContext context) => const ProfileDetailsScreen(),
        );

      case RoutesName.discover:
        return MaterialPageRoute(
          builder: (BuildContext context) => DiscoverScreen(
            searchQuery: settings.arguments is String
                ? settings.arguments as String
                : null,
          ),
        );

      case RoutesName.placeDetails:
        if (settings.arguments is PlaceModel) {
          return MaterialPageRoute(
            builder: (BuildContext context) =>
                PlaceDetailsScreen(place: settings.arguments as PlaceModel),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Invalid Arguments for Place Details')),
          ),
        );

      case RoutesName.tripList:
        return MaterialPageRoute(
          builder: (BuildContext context) => const TripListScreen(),
        );

      case RoutesName.settings:
        return MaterialPageRoute(
          builder: (BuildContext context) => const SettingsScreen(),
        );


      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('No Route Found'))),
        );
    }
  }
}
