import 'package:flutter/material.dart';
import 'package:travel_planner/model/place_model.dart';
import 'package:travel_planner/repository/discovery_repository.dart';
import 'package:travel_planner/data/response/api_response.dart';

class DiscoveryViewModel extends ChangeNotifier {
  final _myRepo = DiscoveryRepository();

  ApiResponse<List<PlaceModel>> placesList = ApiResponse.initial();
  List<String> _selectedKinds = [];
  String? _programmaticSearchQuery;

  int _visibleCount = 25;
  int get visibleCount => _visibleCount;
  List<String> get selectedKinds => _selectedKinds;
  String? get programmaticSearchQuery => _programmaticSearchQuery;

  void setProgrammaticSearchQuery(String? query) {
    _programmaticSearchQuery = query;
    notifyListeners();
  }

  setPlacesList(ApiResponse<List<PlaceModel>> response) {
    placesList = response;
    _visibleCount = 25; // Reset count on new data
    notifyListeners();
  }

  void loadMore() {
    _visibleCount += 25;
    notifyListeners();
  }

  void clearSearch() {
    _selectedKinds = [];
    _visibleCount = 25;
    setPlacesList(ApiResponse.initial());
  }

  void toggleSelectedKind(String kind, String currentCity) {
    if (kind.isEmpty) {
      _selectedKinds = [];
    } else {
      if (_selectedKinds.contains(kind)) {
        _selectedKinds.remove(kind);
      } else {
        _selectedKinds.add(kind);
      }
    }
    notifyListeners();
    if (currentCity.isNotEmpty) {
      fetchPlacesApi(currentCity);
    }
  }

  Future<void> fetchPlacesApi(String city) async {
    setPlacesList(ApiResponse.loading());

    try {
      final coords = await _myRepo.getCoordinates(city);
      final kindsString = _selectedKinds.isEmpty
          ? ''
          : _selectedKinds.join(',');
      final places = await _myRepo.getPlacesByRadius(
        coords['lat']!,
        coords['lon']!,
        kinds: kindsString,
      );

      setPlacesList(ApiResponse.success(places));
    } catch (e) {
      setPlacesList(ApiResponse.error(e.toString()));
    }
  }
}
