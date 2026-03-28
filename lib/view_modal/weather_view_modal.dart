import 'package:flutter/material.dart';
import 'package:travel_planner/data/response/api_response.dart';
import 'package:travel_planner/model/weather_model.dart';
import 'package:travel_planner/repository/weather_repository.dart';

class WeatherViewModel extends ChangeNotifier {
  final _myRepo = WeatherRepository();

  ApiResponse<WeatherModel> weatherData = ApiResponse.initial();

  setWeatherData(ApiResponse<WeatherModel> response) {
    weatherData = response;
    notifyListeners();
  }

  Future<void> fetchWeatherApi(double lat, double lon) async {
    setWeatherData(ApiResponse.loading());

    try {
      final value = await _myRepo.getWeather(lat, lon);
      setWeatherData(ApiResponse.success(value));
    } catch (e) {
      setWeatherData(ApiResponse.error(e.toString()));
    }
  }
}
