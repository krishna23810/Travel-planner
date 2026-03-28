import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travel_planner/data/network/baseApiServices.dart';
import 'package:travel_planner/data/network/networkApiServices.dart';
import 'package:travel_planner/model/weather_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherRepository {
  final BaseApiServices _apiService = NetworkApiServices();

  final String _defaultApiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherModel> getWeather(double lat, double lon) async {
    try {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      final String apiKey = sp.getString('openweather_api_key') ?? _defaultApiKey;

      final url =
          '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

      final response = await _apiService.getApiResponse(url);

      return WeatherModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
