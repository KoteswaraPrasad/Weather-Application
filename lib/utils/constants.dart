import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get openWeatherApiKey {
    return dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  }

  static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';

  static const List<String> defaultCities = [
    'Yellareddy', 'Delhi', 'Hyderabad',
    'Bengaluru', 'Mumbai', 'Kolkata',
  ];
}