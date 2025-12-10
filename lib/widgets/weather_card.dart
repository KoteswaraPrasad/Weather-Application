import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;
  final VoidCallback onTap;

  const WeatherCard({
    Key? key,
    required this.weather,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Weather icon
              Image.network(
                'http://openweathermap.org/img/wn/${weather.iconCode}@2x.png',
                width: 60,
                height: 60,
              ),
              SizedBox(width: 16),

              // City and condition
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          weather.cityName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (weather.isCurrentLocation)
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.my_location, size: 16, color: Colors.blue),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      weather.description,
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'H: ${weather.tempMax.round()}° L: ${weather.tempMin.round()}°',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Temperature
              Text(
                '${weather.currentTemp.round()}°C',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}