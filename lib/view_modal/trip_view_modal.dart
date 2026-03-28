import 'package:flutter/material.dart';
import '../model/trip_model.dart';
import '../model/place_model.dart';
import '../repository/trip_repository.dart';
import 'package:uuid/uuid.dart';

class TripViewModel with ChangeNotifier {
  final TripRepository _repository = TripRepository();
  List<TripModel> _trips = [];
  bool _loading = false;
  String? _expandedTripId;

  List<TripModel> get trips => _trips;
  bool get loading => _loading;
  String? get expandedTripId => _expandedTripId;

  // Stats getters
  int get totalTrips => _trips.length;
  
  int get totalPlaces => _trips.fold(0, (sum, trip) => sum + trip.places.length);

  int get totalTravelDays =>
      _trips.fold(0, (sum, trip) => sum + trip.durationDays);

  void setExpandedTripId(String? id) {
    _expandedTripId = id;
    notifyListeners();
  }

  TripViewModel() {
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    _loading = true;
    notifyListeners();
    _trips = await _repository.getTrips();
    _loading = false;
    notifyListeners();
  }

  Future<String> createTrip(String title, DateTime start, int durationDays) async {
    final id = const Uuid().v4();
    final newTrip = TripModel(
      id: id,
      title: title,
      startDate: start,
      durationDays: durationDays,
    );
    await _repository.addTrip(newTrip);
    await fetchTrips();
    return id;
  }

  Future<void> addPlaceToTrip(String tripId, PlaceModel place) async {
    final tripIndex = _trips.indexWhere((t) => t.id == tripId);
    if (tripIndex != -1) {
      _trips[tripIndex].places.add({
        'place': place,
        'isVisited': false,
      });
      await _repository.saveTrips(_trips);
      notifyListeners();
    }
  }

  Future<void> togglePlaceVisited(String tripId, String placeXid) async {
    await _repository.toggleVisitedStatus(tripId, placeXid);
    await fetchTrips();
  }

  Future<void> updateTrip(
    String tripId,
    String newTitle,
    DateTime newStart,
    int newDuration,
  ) async {
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      final trip = _trips[index];
      trip.title = newTitle;
      trip.startDate = newStart;
      trip.durationDays = newDuration;

      await _repository.saveTrips(_trips);
      notifyListeners();
    }
  }

  Future<void> removeTrip(String tripId) async {
    await _repository.deleteTrip(tripId);
    await fetchTrips();
  }

  Future<void> clearAllTrips() async {
    await _repository.clearTrips();
    _trips = [];
    notifyListeners();
  }
}

