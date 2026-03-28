import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travel_planner/data/network/baseApiServices.dart';
import 'package:travel_planner/data/network/networkApiServices.dart';
import 'package:travel_planner/model/place_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscoveryRepository {
  BaseApiServices _apiService = NetworkApiServices();

  final String _defaultApiKey = dotenv.env['OPENTRIPMAP_API_KEY'] ?? '';

  final String _baseUrl = 'https://api.opentripmap.com/0.1/en';

  Future<String> _getApiKey() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('opentripmap_api_key') ?? _defaultApiKey;
  }

  Future<Map<String, double>> getCoordinates(String cityName) async {
    try {
      final apiKey = await _getApiKey();
      final url =
          '$_baseUrl/places/geoname?name=$cityName&country=in&apikey=$apiKey';

      final response = await _apiService.getApiResponse(url);

      return {
        'lat': response['lat'].toDouble(),
        'lon': response['lon'].toDouble(),
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PlaceModel>> getPlacesByRadius(
    double lat,
    double lon, {
    int radius = 25000,
    String? kinds,
  }) async {
    try {
      final apiKey = await _getApiKey();
      String url =
          '$_baseUrl/places/radius?radius=$radius&lon=$lon&lat=$lat&format=json&limit=500&apikey=$apiKey';
      if (kinds != null && kinds.isNotEmpty) {
        url += '&kinds=$kinds';
      }
      final response = await _apiService.getApiResponse(url);

      if (response is List) {
        // Use compute to parse large lists in background isolate to prevent main thread lag (Davey)
        return await compute(_parsePlacesList, response);
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Top-level function for compute()
  static List<PlaceModel> _parsePlacesList(dynamic response) {
    List<PlaceModel> places = [];
    if (response is List) {
      for (var item in response) {
        if (item['name'] != null && item['name'].toString().isNotEmpty) {
          places.add(PlaceModel.fromJson(item));
        }
      }
    }
    return places;
  }

  Future<PlaceModel> getPlaceDetails(String xid) async {
    try {
      final apiKey = await _getApiKey();
      final url = '$_baseUrl/places/xid/$xid?apikey=$apiKey';
      final response = await _apiService.getApiResponse(url);
      debugPrint("PlaceDetails: ${response.toString()}");
      return PlaceModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
