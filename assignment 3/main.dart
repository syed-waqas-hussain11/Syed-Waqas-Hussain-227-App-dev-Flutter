import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String _city = 'Loading...';
  double _temperature = 0;
  String _condition = 'Loading...';
  int _humidity = 0;
  int _windSpeed = 0;
  double _feelsLike = 0;
  bool _isLoading = true;
  String _errorMessage = '';
  late TextEditingController _cityController;
  
  // New features
  double _visibility = 0;
  int _pressure = 0;
  int _cloudCover = 0;
  String _sunriseTime = '';
  String _sunsetTime = '';
  final List<String> _recentCities = [];

  final String _apiKey = 'b99c3f912d04d4108ecc8c7dfc592072';
  final List<Map<String, dynamic>> _forecastData = [
    {'day': 'Mon', 'high': 75, 'low': 65, 'condition': '☀️'},
    {'day': 'Tue', 'high': 73, 'low': 63, 'condition': '⛅'},
    {'day': 'Wed', 'high': 68, 'low': 58, 'condition': '🌧️'},
    {'day': 'Thu', 'high': 70, 'low': 60, 'condition': '⛅'},
    {'day': 'Fri', 'high': 76, 'low': 66, 'condition': '☀️'},
  ];

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController();
    _fetchWeatherByLocation();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _getLocationAndWeather() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied';
          _isLoading = false;
        });
        return;
      }

      Position? position;

      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 30),
        );
      } catch (e) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null ||
          (position.latitude == 0 && position.longitude == 0)) {
        throw Exception(
          'Could not determine device location. Please ensure location services are enabled and GPS is available.',
        );
      }

      await _fetchWeatherData(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherByLocation() async {
    await _getLocationAndWeather();
  }

  Future<void> _fetchWeatherByCity(String cityName) async {
    if (cityName.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a city name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$_apiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse sunrise and sunset times
        int sunriseTimestamp = data['sys']['sunrise'] ?? 0;
        int sunsetTimestamp = data['sys']['sunset'] ?? 0;
        String sunrise = _formatTime(DateTime.fromMillisecondsSinceEpoch(sunriseTimestamp * 1000));
        String sunset = _formatTime(DateTime.fromMillisecondsSinceEpoch(sunsetTimestamp * 1000));
        
        setState(() {
          _city = data['name'] ?? cityName;
          _temperature = (data['main']['temp'] as num).toDouble();
          _condition = data['weather'][0]['main'] ?? 'Unknown';
          _humidity = data['main']['humidity'] ?? 0;
          _windSpeed = (data['wind']['speed'] as num).toInt();
          _feelsLike = (data['main']['feels_like'] as num).toDouble();
          _visibility = (data['visibility'] ?? 0) / 1000.0;
          _pressure = data['main']['pressure'] ?? 0;
          _cloudCover = data['clouds']['all'] ?? 0;
          _sunriseTime = sunrise;
          _sunsetTime = sunset;
          
          // Add to recent cities
          if (!_recentCities.contains(_city)) {
            _recentCities.insert(0, _city);
            if (_recentCities.length > 5) {
              _recentCities.removeLast();
            }
          }
          
          _isLoading = false;
          _errorMessage = '';
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'City not found. Please try again.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch weather data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherData(double latitude, double longitude) async {
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Parse sunrise and sunset times
        int sunriseTimestamp = data['sys']['sunrise'] ?? 0;
        int sunsetTimestamp = data['sys']['sunset'] ?? 0;
        String sunrise = _formatTime(DateTime.fromMillisecondsSinceEpoch(sunriseTimestamp * 1000));
        String sunset = _formatTime(DateTime.fromMillisecondsSinceEpoch(sunsetTimestamp * 1000));
        
        setState(() {
          _city = data['name'] ?? 'Unknown';
          _temperature = (data['main']['temp'] as num).toDouble();
          _condition = data['weather'][0]['main'] ?? 'Unknown';
          _humidity = data['main']['humidity'] ?? 0;
          _windSpeed = (data['wind']['speed'] as num).toInt();
          _feelsLike = (data['main']['feels_like'] as num).toDouble();
          _visibility = (data['visibility'] ?? 0) / 1000.0;
          _pressure = data['main']['pressure'] ?? 0;
          _cloudCover = data['clouds']['all'] ?? 0;
          _sunriseTime = sunrise;
          _sunsetTime = sunset;
          
          // Add to recent cities
          if (!_recentCities.contains(_city)) {
            _recentCities.insert(0, _city);
            if (_recentCities.length > 5) {
              _recentCities.removeLast();
            }
          }
          
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch weather data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search City'),
          content: TextField(
            controller: _cityController,
            decoration: const InputDecoration(
              hintText: 'Enter city name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _fetchWeatherByCity(_cityController.text);
                _cityController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getWeatherAdvice() {
    if (_condition.contains('Rain')) {
      return '☔ Bring an umbrella!';
    } else if (_condition.contains('Snow')) {
      return '❄️ Dress warmly!';
    } else if (_condition.contains('Storm')) {
      return '⚡ Stay safe indoors!';
    } else if (_temperature > 35) {
      return '☀️ Stay hydrated!';
    } else if (_temperature < 0) {
      return '🧊 Very cold, dress heavy!';
    } else if (_windSpeed > 30) {
      return '💨 Very windy today!';
    } else {
      return '😊 Great weather!';
    }
  }

  String _getAQIStatus() {
    // Simplified AQI based on visibility
    if (_visibility > 10) return '✅ Good';
    if (_visibility > 5) return '🟡 Moderate';
    return '🔴 Poor';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weather App'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weather App'),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _fetchWeatherByLocation,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF667EEA),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF667EEA),
              const Color(0xFF764BA2),
              const Color(0xFFD62828),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Weather Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        Colors.white.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Text(
                        _city,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667EEA),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${_temperature.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF764BA2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _condition,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color(0xFF667EEA),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Feels like ${_feelsLike.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                // Weather Advice Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.9),
                        Colors.orange.withValues(alpha: 0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Advice',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getWeatherAdvice(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Weather Details
                Text(
                  'Weather Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        'Humidity',
                        '$_humidity%',
                        Icons.opacity,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildDetailCard(
                        'Wind Speed',
                        '$_windSpeed m/s',
                        Icons.air,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        'Pressure',
                        '$_pressure hPa',
                        Icons.speed,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildDetailCard(
                        'Cloud Cover',
                        '$_cloudCover%',
                        Icons.cloud,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailCard(
                        'Visibility',
                        '${_visibility.toStringAsFixed(1)} km',
                        Icons.visibility,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildDetailCard(
                        'Air Quality',
                        _getAQIStatus(),
                        Icons.health_and_safety,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // Sunrise & Sunset Section
                Text(
                  'Sun Times',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.withValues(alpha: 0.9),
                              Colors.red.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.wb_sunny, color: Colors.white, size: 32),
                            const SizedBox(height: 8),
                            const Text(
                              'Sunrise',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _sunriseTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.withValues(alpha: 0.9),
                              Colors.purple.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.nights_stay, color: Colors.white, size: 32),
                            const SizedBox(height: 8),
                            const Text(
                              'Sunset',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _sunsetTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // Recent Cities
                if (_recentCities.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Cities',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _recentCities.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () {
                                  _fetchWeatherByCity(_recentCities[index]);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.9),
                                        Colors.white.withValues(alpha: 0.8),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _recentCities[index],
                                      style: const TextStyle(
                                        color: Color(0xFF667EEA),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 35),
                    ],
                  ),

                // 5-Day Forecast
                Text(
                  '5-Day Forecast',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _forecastData.length,
                    itemBuilder: (context, index) {
                      final forecast = _forecastData[index];
                      return Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.95),
                              Colors.white.withValues(alpha: 0.85),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              forecast['day'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF667EEA),
                              ),
                            ),
                            Text(
                              forecast['condition'],
                              style: const TextStyle(fontSize: 40),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${forecast['high']}°',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF764BA2),
                                  ),
                                ),
                                Text(
                                  '${forecast['low']}°',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchWeatherByLocation,
        tooltip: 'Refresh Weather',
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF667EEA),
        elevation: 10,
        child: const Icon(Icons.refresh, size: 28),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF667EEA),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF764BA2),
            ),
          ),
        ],
      ),
    );
  }
}
