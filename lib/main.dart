import 'package:flutter/material.dart';

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isCelsius = true;
  String _searchQuery = '';
  Map<String, dynamic>? _selectedCity;

  // Static weather data
  final List<Map<String, dynamic>> _cities = [
    {
      "name": "Yellareddy",
      "currentTemp": 25,
      "condition": "Cloudy",
      "highLow": "29° / 24°",
      "feelsLike": 25,
      "hourlyForecast": [
        {"time": "9:30 pm", "temp": 25, "precip": 6},
        {"time": "10:30 pm", "temp": 25, "precip": 6},
        {"time": "11:30 pm", "temp": 25, "precip": 7},
        {"time": "12:30 am", "temp": 25, "precip": 9},
        {"time": "1:30 am", "temp": 25, "precip": 10},
      ],
      "tomorrow": {"condition": "Cloudy", "high": 30},
      "yesterday": {"high": 29, "low": 24},
      "color": Colors.blueGrey,
      "icon": Icons.cloud,
    },
    {
      "name": "Delhi",
      "currentTemp": 32,
      "condition": "Sunny",
      "highLow": "35° / 28°",
      "feelsLike": 34,
      "hourlyForecast": [
        {"time": "9:30 pm", "temp": 31, "precip": 2},
        {"time": "10:30 pm", "temp": 30, "precip": 2},
        {"time": "11:30 pm", "temp": 29, "precip": 3},
        {"time": "12:30 am", "temp": 28, "precip": 4},
        {"time": "1:30 am", "temp": 28, "precip": 5},
      ],
      "tomorrow": {"condition": "Partly Cloudy", "high": 36},
      "yesterday": {"high": 34, "low": 27},
      "color": Colors.orange,
      "icon": Icons.wb_sunny,
    },
    {
      "name": "Hyderabad",
      "currentTemp": 28,
      "condition": "Partly Cloudy",
      "highLow": "31° / 26°",
      "feelsLike": 29,
      "hourlyForecast": [
        {"time": "9:30 pm", "temp": 28, "precip": 10},
        {"time": "10:30 pm", "temp": 27, "precip": 15},
        {"time": "11:30 pm", "temp": 27, "precip": 20},
        {"time": "12:30 am", "temp": 26, "precip": 25},
        {"time": "1:30 am", "temp": 26, "precip": 30},
      ],
      "tomorrow": {"condition": "Rainy", "high": 30},
      "yesterday": {"high": 32, "low": 25},
      "color": Colors.blue,
      "icon": Icons.cloud_queue,
    },
    {
      "name": "Bengaluru",
      "currentTemp": 22,
      "condition": "Rainy",
      "highLow": "25° / 20°",
      "feelsLike": 21,
      "hourlyForecast": [
        {"time": "9:30 pm", "temp": 22, "precip": 60},
        {"time": "10:30 pm", "temp": 22, "precip": 65},
        {"time": "11:30 pm", "temp": 21, "precip": 70},
        {"time": "12:30 am", "temp": 21, "precip": 75},
        {"time": "1:30 am", "temp": 20, "precip": 80},
      ],
      "tomorrow": {"condition": "Rainy", "high": 24},
      "yesterday": {"high": 26, "low": 19},
      "color": Colors.indigo,
      "icon": Icons.umbrella,
    },
    {
      "name": "Mumbai",
      "currentTemp": 30,
      "condition": "Humid",
      "highLow": "32° / 28°",
      "feelsLike": 33,
      "hourlyForecast": [
        {"time": "9:30 pm", "temp": 30, "precip": 40},
        {"time": "10:30 pm", "temp": 30, "precip": 45},
        {"time": "11:30 pm", "temp": 29, "precip": 50},
        {"time": "12:30 am", "temp": 29, "precip": 55},
        {"time": "1:30 am", "temp": 28, "precip": 60},
      ],
      "tomorrow": {"condition": "Thunderstorm", "high": 31},
      "yesterday": {"high": 33, "low": 27},
      "color": Colors.deepPurple,
      "icon": Icons.grain,
    },
    {
      "name": "Kolkata",
      "currentTemp": 31,
      "condition": "Hazy",
      "highLow": "33° / 29°",
      "feelsLike": 34,
      "hourlyForecast": [
        {"time": "9:30 pm", "temp": 31, "precip": 20},
        {"time": "10:30 pm", "temp": 31, "precip": 25},
        {"time": "11:30 pm", "temp": 30, "precip": 30},
        {"time": "12:30 am", "temp": 30, "precip": 35},
        {"time": "1:30 am", "temp": 29, "precip": 40},
      ],
      "tomorrow": {"condition": "Foggy", "high": 32},
      "yesterday": {"high": 34, "low": 28},
      "color": Colors.brown,
      "icon": Icons.filter_drama,
    },
  ];

  // Get filtered cities based on search query
  List<Map<String, dynamic>> get _filteredCities {
    if (_searchQuery.isEmpty) {
      return _cities;
    }
    return _cities.where((city) {
      return city["name"].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Convert Celsius to Fahrenheit
  double _convertCtoF(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  // Format temperature based on current unit
  String _formatTemp(double temp) {
    return _isCelsius ? '${temp.round()}°C' : '${_convertCtoF(temp).round()}°F';
  }

  // Format high/low temperature pair
  String _formatHighLow(double high, double low) {
    if (_isCelsius) {
      return '${high.round()}° / ${low.round()}°';
    } else {
      return '${_convertCtoF(high).round()}° / ${_convertCtoF(low).round()}°';
    }
  }

  void _toggleTempUnit() {
    setState(() {
      _isCelsius = !_isCelsius;
    });
  }

  void _showCityDetails(Map<String, dynamic> city) {
    setState(() {
      _selectedCity = city;
    });
  }

  void _goBack() {
    setState(() {
      _selectedCity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCity == null ? "Weather App" : _selectedCity!["name"]),
        leading: _selectedCity != null
            ? IconButton(icon: Icon(Icons.arrow_back), onPressed: _goBack)
            : null,
        actions: [
          IconButton(
            icon: Icon(_isCelsius ? Icons.thermostat : Icons.thermostat_outlined),
            onPressed: _toggleTempUnit,
            tooltip: _isCelsius ? 'Switch to Fahrenheit' : 'Switch to Celsius',
          ),
        ],
      ),
      body: _selectedCity == null ? _buildCityList() : _buildCityDetails(),
    );
  }

  Widget _buildCityList() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search cities...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: _filteredCities.isEmpty
              ? Center(
            child: Text(
              "No cities found",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: _filteredCities.length,
            itemBuilder: (context, index) {
              final city = _filteredCities[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(city["icon"], color: city["color"], size: 40),
                  title: Text(city["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(city["condition"]),
                  trailing: Text(
                    _formatTemp(city["currentTemp"].toDouble()),
                    style: TextStyle(fontSize: 24),
                  ),
                  onTap: () => _showCityDetails(city),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCityDetails() {
    final city = _selectedCity!;
    final highLow = city["highLow"].toString().split(" / ");
    final high = double.parse(highLow[0].replaceAll("°", ""));
    final low = double.parse(highLow[1].replaceAll("°", ""));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current weather
          Row(
            children: [
              Text(
                _formatTemp(city["currentTemp"].toDouble()),
                style: TextStyle(fontSize: 48),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city["condition"], style: TextStyle(fontSize: 18)),
                  Text(_formatHighLow(high, low), style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Text("Feels like ${_formatTemp(city["feelsLike"].toDouble())}",
              style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16),

          // Hourly forecast
          Text("Hourly Forecast", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...city["hourlyForecast"].map((hour) => Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Text(hour["time"]),
                      SizedBox(height: 4),
                      Text(_formatTemp(hour["temp"].toDouble())),
                      SizedBox(height: 4),
                      Text("${hour["precip"]}%"),
                    ],
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Tomorrow's outlook
          Text("Tomorrow's Outlook", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("${city["tomorrow"]["condition"]}. High of ${_formatTemp(city["tomorrow"]["high"].toDouble())}"),
          SizedBox(height: 24),

          // Yesterday
          Text("Yesterday", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("H: ${_formatTemp(city["yesterday"]["high"].toDouble())} L: ${_formatTemp(city["yesterday"]["low"].toDouble())}"),
        ],
      ),
    );
  }
}