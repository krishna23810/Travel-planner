import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/trip_model.dart';
import '../model/place_model.dart';

class TripRepository {
  static const String _tripsKey = 'user_trips';

  Future<List<TripModel>> getTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tripsString = prefs.getString(_tripsKey);
    if (tripsString == null) return [];

    final List<dynamic> tripsJson = jsonDecode(tripsString);
    return tripsJson.map((json) => TripModel.fromJson(json)).toList();
  }

  Future<void> saveTrips(List<TripModel> trips) async {
    final prefs = await SharedPreferences.getInstance();
    final String tripsString = jsonEncode(trips.map((t) => t.toJson()).toList());
    await prefs.setString(_tripsKey, tripsString);
  }

  Future<void> addTrip(TripModel trip) async {
    final trips = await getTrips();
    trips.add(trip);
    await saveTrips(trips);
  }

  Future<void> addPlaceToTrip(String tripId, PlaceModel place) async {
    final trips = await getTrips();
    final index = trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      // Check if place already exists in trip to avoid duplicates
      if (!trips[index].places.any((p) => (p['place'] as PlaceModel).xid == place.xid)) {
        trips[index].places.add({'place': place, 'isVisited': false});
        await saveTrips(trips);
      }
    }
  }

  Future<void> toggleVisitedStatus(String tripId, String placeXid) async {
    final trips = await getTrips();
    final tripIndex = trips.indexWhere((t) => t.id == tripId);
    if (tripIndex != -1) {
      final placeIndex = trips[tripIndex].places.indexWhere(
        (p) => (p['place'] as PlaceModel).xid == placeXid,
      );
      if (placeIndex != -1) {
        final currentStatus = trips[tripIndex].places[placeIndex]['isVisited'] as bool;
        trips[tripIndex].places[placeIndex]['isVisited'] = !currentStatus;
        await saveTrips(trips);
      }
    }
  }

  Future<void> deleteTrip(String tripId) async {
    final trips = await getTrips();
    trips.removeWhere((t) => t.id == tripId);
    await saveTrips(trips);
  }

  Future<void> clearTrips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tripsKey);
  }
}
