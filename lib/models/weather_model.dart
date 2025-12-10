class WeatherData {
  final String cityName;
  final double currentTemp;
  final String condition;
  final String description;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String iconCode;
  final bool isCurrentLocation;

  WeatherData({
    required this.cityName,
    required this.currentTemp,
    required this.condition,
    required this.description,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
    this.isCurrentLocation = false,
  });

  // Factory method to create from API response
  factory WeatherData.fromApiJson(Map<String, dynamic> json, {bool isCurrentLocation = false}) {
    return WeatherData(
      cityName: json['name'],
      currentTemp: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      feelsLike: json['main']['feels_like'].toDouble(),
      tempMin: json['main']['temp_min'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      iconCode: json['weather'][0]['icon'],
      isCurrentLocation: isCurrentLocation,
    );
  }
}