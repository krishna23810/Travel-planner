import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:travel_planner/utils/routes/routes.dart';
import 'package:travel_planner/utils/routes/routes_name.dart';
import 'package:travel_planner/view_modal/discovery_view_modal.dart';
import 'package:travel_planner/view_modal/user_view_modal.dart';
import 'package:travel_planner/view_modal/trip_view_modal.dart';
import 'package:travel_planner/view_modal/weather_view_modal.dart';
import 'package:travel_planner/view_modal/main_view_model.dart';
import 'package:travel_planner/view_modal/settings_view_model.dart';


import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => DiscoveryViewModel()),
        ChangeNotifierProvider(create: (_) => WeatherViewModel()),
        ChangeNotifierProvider(create: (_) => TripViewModel()),
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],

      child: MaterialApp(
        title: 'Travel Planner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
          ),
        ),
        initialRoute: RoutesName.splash,
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }
}
