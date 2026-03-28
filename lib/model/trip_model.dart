import 'place_model.dart';

class TripModel {
  String id;
  String title;
  DateTime startDate;
  int durationDays;
  // list of places with true or false value
  // true means visted and false means not visted
  // so list have two value place and boolean

  List<Map<String, dynamic>> places;

  TripModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.durationDays,
    List<Map<String, dynamic>>? places,
  }) : this.places = places ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'durationDays': durationDays,
      'places': places.map((item) => {
        'place': (item['place'] as PlaceModel).toJson(),
        'isVisited': item['isVisited'] ?? false,
      }).toList(),
    };
  }

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      durationDays: json['durationDays'] ?? 1,
      places: json['places'] != null
          ? (json['places'] as List).map((item) {
              if (item is Map<String, dynamic> && item.containsKey('place')) {
                return {
                  'place': PlaceModel.fromJson(item['place']),
                  'isVisited': item['isVisited'] ?? false,
                };
              } else {
                // Handle legacy format or direct PlaceModel JSON
                return {
                  'place': PlaceModel.fromJson(item as Map<String, dynamic>),
                  'isVisited': false,
                };
              }
            }).toList()
          : [],
    );
  }
}
