class WeatherModel {
  final double temp;
  final String main;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;

  WeatherModel({
    required this.temp,
    required this.main,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temp: (json['main']['temp'] as num).toDouble(),
      main: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'main': main,
      'description': description,
      'icon': icon,
      'humidity': humidity,
      'windSpeed': windSpeed,
    };
  }
}
