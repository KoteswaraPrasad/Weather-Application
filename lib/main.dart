import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'services/weather_service.dart';
import 'models/weather_model.dart';
import 'widgets/weather_card.dart';
import 'utils/constants.dart';

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
  List<WeatherData> _weatherList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';

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
      List<WeatherData> loadedWeather = [];

      // Try to get current location weather
      try {
        final locationWeather = await WeatherService.getCurrentLocationWeather();
        loadedWeather.add(locationWeather);
      } catch (e) {
        print('Could not get location: $e');
      }

      // Get weather for default cities
      for (String city in AppConstants.defaultCities) {
        try {
          final weather = await WeatherService.getCityWeather(city);
          loadedWeather.add(weather);
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
        _errorMessage = 'Failed to load weather data: $e';
        _isLoading = false;
      });
    }
  }

  List<WeatherData> get _filteredWeather {
    if (_searchQuery.isEmpty) return _weatherList;
    return _weatherList.where((weather) {
      return weather.cityName.toLowerCase().contains(_searchQuery.toLowerCase());
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

  Widget _buildWeatherList() {
    if (_filteredWeather.isEmpty) {
      return Center(
        child: Text(
          'No cities found',
          style: TextStyle(fontSize: 18, color: Colors.grey),
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
          return WeatherCard(
            weather: weather,
            onTap: () {
              _showWeatherDetails(weather);
            },
          );
        },
      ),
    );
  }

  void _showWeatherDetails(WeatherData weather) {
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
                          'http://openweathermap.org/img/wn/${weather.iconCode}@4x.png',
                          width: 80,
                          height: 80,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weather.cityName,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                weather.description,
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
                      '${weather.currentTemp.round()}°C',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Feels like ${weather.feelsLike.round()}°C',
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
                        _buildDetailItem('High', '${weather.tempMax.round()}°C', Icons.arrow_upward),
                        _buildDetailItem('Low', '${weather.tempMin.round()}°C', Icons.arrow_downward),
                        _buildDetailItem('Humidity', '${weather.humidity}%', Icons.water_drop),
                        _buildDetailItem('Wind', '${weather.windSpeed.round()} km/h', Icons.air),
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
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search cities...',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add city dialog
        },
        child: Icon(Icons.add_location),
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