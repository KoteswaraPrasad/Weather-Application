import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

void main() {
  runApp(MyWeatherApp());
}

class MyWeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Weather Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WeatherHomeScreen(),
    );
  }
}

class WeatherHomeScreen extends StatefulWidget {
  @override
  _WeatherHomeScreenState createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  List<Map<String, dynamic>> _weatherList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Your API key
  static const String _apiKey = 'c08f3fc0b400b3de42f22eab216203ff';

  @override
  void initState() {
    super.initState();
    _loadAllWeather();
  }

  Future<void> _loadAllWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<Map<String, dynamic>> loadedWeather = [];

      // 1. FIRST: Try to get LIVE LOCATION weather
      try {
        final locationWeather = await _getCurrentLocationWeather();
        loadedWeather.add({...locationWeather, 'isCurrentLocation': true});
      } catch (e) {
        print('Location error: $e');
        // Continue without location
      }

      // 2. Load default cities
      final List<String> defaultCities = ['Delhi', 'Mumbai', 'Hyderabad', 'Bengaluru', 'Kolkata'];

      for (String city in defaultCities) {
        try {
          final weather = await _getCityWeather(city);
          loadedWeather.add({...weather, 'isCurrentLocation': false});
        } catch (e) {
          print('Failed to load $city: $e');
        }
      }

      setState(() {
        _weatherList = loadedWeather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load weather data';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getCurrentLocationWeather() async {
    // Check and request permissions
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

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric'
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'cityName': '📍 ${data['name']} (Your Location)',
        'currentTemp': data['main']['temp'],
        'condition': data['weather'][0]['main'],
        'description': data['weather'][0]['description'],
        'feelsLike': data['main']['feels_like'],
        'tempMin': data['main']['temp_min'],
        'tempMax': data['main']['temp_max'],
        'humidity': data['main']['humidity'],
        'windSpeed': data['wind']['speed'],
        'iconCode': data['weather'][0]['icon'],
      };
    } else {
      throw Exception('Failed to get location weather');
    }
  }

  Future<Map<String, dynamic>> _getCityWeather(String cityName) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$_apiKey&units=metric'
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'cityName': data['name'],
        'currentTemp': data['main']['temp'],
        'condition': data['weather'][0]['main'],
        'description': data['weather'][0]['description'],
        'feelsLike': data['main']['feels_like'],
        'tempMin': data['main']['temp_min'],
        'tempMax': data['main']['temp_max'],
        'humidity': data['main']['humidity'],
        'windSpeed': data['wind']['speed'],
        'iconCode': data['weather'][0]['icon'],
      };
    } else if (response.statusCode == 404) {
      throw Exception('City "$cityName" not found');
    } else {
      throw Exception('API Error ${response.statusCode}');
    }
  }

  Future<void> _searchCity(String cityName) async {
    if (cityName.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final weather = await _getCityWeather(cityName);

      // Check if city already exists
      final existingIndex = _weatherList.indexWhere(
              (w) => w['cityName'].toString().toLowerCase() == cityName.toLowerCase()
      );

      setState(() {
        if (existingIndex >= 0) {
          _weatherList[existingIndex] = {...weather, 'isCurrentLocation': false};
        } else {
          _weatherList.insert(1, {...weather, 'isCurrentLocation': false}); // Insert after location
        }
        _isSearching = false;
        _searchController.clear();
        _searchQuery = '';
      });

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Weather for $cityName loaded!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'City not found: $cityName';
        _isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ City "$cityName" not found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredWeather {
    if (_searchQuery.isEmpty) return _weatherList;
    return _weatherList.where((weather) {
      return weather['cityName'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitFadingCircle(
              color: Colors.blue,
              size: 50.0,
            ),
            SizedBox(height: 20),
            Text(
              'Fetching live weather...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              '📍 Detecting your location',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'Error Loading Weather',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loadAllWeather,
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(Map<String, dynamic> weather) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _showWeatherDetails(weather),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Weather icon
              Image.network(
                'http://openweathermap.org/img/wn/${weather['iconCode']}@2x.png',
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
                          weather['cityName'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (weather['isCurrentLocation'] == true)
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.my_location, size: 16, color: Colors.blue),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      weather['description'],
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'H: ${weather['tempMax'].round()}° L: ${weather['tempMin'].round()}°',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Temperature
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${weather['currentTemp'].round()}°C',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Feels like ${weather['feelsLike'].round()}°C',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherList() {
    if (_filteredWeather.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No cities found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Try searching for a different city',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllWeather,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 80),
        itemCount: _filteredWeather.length,
        itemBuilder: (context, index) {
          final weather = _filteredWeather[index];
          return _buildWeatherCard(weather);
        },
      ),
    );
  }

  void _showWeatherDetails(Map<String, dynamic> weather) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  // Header with city name
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Image.network(
                          'http://openweathermap.org/img/wn/${weather['iconCode']}@4x.png',
                          width: 80,
                          height: 80,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    weather['cityName'].toString().replaceAll('📍 ', '').replaceAll(' (Your Location)', ''),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (weather['isCurrentLocation'] == true)
                                    Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Icon(Icons.my_location, size: 20, color: Colors.blue),
                                    ),
                                ],
                              ),
                              Text(
                                weather['description'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Temperature highlight
                  Center(
                    child: Text(
                      '${weather['currentTemp'].round()}°C',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Feels like ${weather['feelsLike'].round()}°C',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  Divider(height: 40),

                  // Weather details grid
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: [
                        _buildDetailItem('High', '${weather['tempMax'].round()}°C', Icons.arrow_upward),
                        _buildDetailItem('Low', '${weather['tempMin'].round()}°C', Icons.arrow_downward),
                        _buildDetailItem('Humidity', '${weather['humidity']}%', Icons.water_drop),
                        _buildDetailItem('Wind', '${weather['windSpeed'].round()} km/h', Icons.air),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen();
    if (_errorMessage.isNotEmpty) return _buildErrorScreen();

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Weather Pro'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAllWeather,
            tooltip: 'Refresh all weather',
          ),
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () async {
              try {
                setState(() => _isLoading = true);
                final locationWeather = await _getCurrentLocationWeather();
                final existingIndex = _weatherList.indexWhere(
                        (w) => w['isCurrentLocation'] == true
                );

                setState(() {
                  if (existingIndex >= 0) {
                    _weatherList[existingIndex] = {...locationWeather, 'isCurrentLocation': true};
                  } else {
                    _weatherList.insert(0, {...locationWeather, 'isCurrentLocation': true});
                  }
                  _isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('📍 Location updated!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Location access denied'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            tooltip: 'Update location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar with button
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search any city (e.g., London, Tokyo, Paris)',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _searchCity(value);
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                _isSearching
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    if (_searchController.text.trim().isNotEmpty) {
                      _searchCity(_searchController.text);
                    }
                  },
                  child: Text('Search'),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(15),
                  ),
                ),
              ],
            ),
          ),

          // Weather stats header
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.location_on, '${_weatherList.length}', 'Cities'),
                _buildStatItem(Icons.cloud, 'Live', 'Weather'),
                _buildStatItem(Icons.update, 'Now', 'Updated'),
              ],
            ),
          ),

          // Weather list
          Expanded(child: _buildWeatherList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Add City'),
              content: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  labelText: 'City',
                ),
                onSubmitted: (value) {
                  Navigator.pop(context);
                  _searchCity(value);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final city = (context as Element).findAncestorWidgetOfExactType<AlertDialog>()?.content is TextField
                        ? (_searchController.text)
                        : '';
                    if (city.isNotEmpty) {
                      Navigator.pop(context);
                      _searchCity(city);
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          );
        },
        icon: Icon(Icons.add_location),
        label: Text('Add City'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}