import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart';
import '../models/weather_model.dart';

class WeatherService {
  // Get REAL weather for a city
  static Future<WeatherData> getCityWeather(String cityName) async {
    final apiKey = AppConstants.openWeatherApiKey;

    if (apiKey.isEmpty) {
      throw Exception('API key not configured. Check .env file.');
    }

    final response = await http.get(
      Uri.parse(
          '${AppConstants.openWeatherBaseUrl}/weather?q=$cityName&appid=$apiKey&units=metric'
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData.fromApiJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('City "$cityName" not found');
    } else {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }

  // Get REAL weather for current location
  static Future<WeatherData> getCurrentLocationWeather() async {
    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permanently denied. Enable in settings.');
    }

    // Get position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    final apiKey = AppConstants.openWeatherApiKey;

    if (apiKey.isEmpty) {
      throw Exception('API key not configured');
    }

    final response = await http.get(
      Uri.parse(
          '${AppConstants.openWeatherBaseUrl}/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric'
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WeatherData.fromApiJson(data, isCurrentLocation: true);
    } else {
      throw Exception('Failed to get location weather: ${response.statusCode}');
    }
  }
}