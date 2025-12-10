import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart';
import '../models/weather_model.dart';

class WeatherService {
  // Get weather for a specific city
  static Future<WeatherData> getCityWeather(String cityName) async {
    final response = await http.get(
      Uri.parse(
          '${AppConstants.openWeatherBaseUrl}/weather?q=$cityName&appid=${AppConstants.openWeatherApiKey}&units=metric'
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData.fromApiJson(data);
    } else {
      throw Exception('Failed to load weather for $cityName');
    }
  }

  // UNIQUE FEATURE: Get weather for current location
  static Future<WeatherData> getCurrentLocationWeather() async {
    // Check and request location permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied. Please enable location services.');
      }
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    // Fetch weather for coordinates
    final response = await http.get(
      Uri.parse(
          '${AppConstants.openWeatherBaseUrl}/weather?lat=${position.latitude}&lon=${position.longitude}&appid=${AppConstants.openWeatherApiKey}&units=metric'
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData.fromApiJson(data, isCurrentLocation: true);
    } else {
      throw Exception('Failed to load weather for your location');
    }
  }
}