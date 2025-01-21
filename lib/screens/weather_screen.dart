import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../models/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();

    // Load weather for current location when the screen initializes
    _loadInitialWeather();
  }
  
  // Load initial weather data
  Future<void> _loadInitialWeather() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    Provider.of<WeatherProvider>(context, listen: false)
        .fetchWeatherByCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (ctx, weatherProvider, _) {
          // Handle loading state
          if (weatherProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Fetching weather data...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          } 
          
          // Handle error state
          if (weatherProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[300],
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error occurred',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weatherProvider.error ?? '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        weatherProvider.fetchWeatherByCurrentLocation();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Handle no data state
          if (weatherProvider.weatherData == null) {
            return const Center(
              child: Text('No weather data available. Search for a city or use your location.'),
            );
          }

          // Weather data available
          final weather = weatherProvider.weatherData!;
          final now = DateTime.now();
          final dateFormat = DateFormat('EEEE, MMM d, yyyy');
          final timeFormat = DateFormat('h:mm a');
          
          // Get appropriate background gradient based on weather and time
          final gradient = _getBackgroundGradient(weather.description, now.hour, isDark);

          return Container(
            decoration: BoxDecoration(gradient: gradient),
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: SafeArea(
                child: Column(
                  children: [
                    // App Bar with search and theme toggle
                    _buildAppBar(context),
                    
                    // Weather Content
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          const SizedBox(height: 10),
                          
                          // Date and Time
                          Text(
                            dateFormat.format(now),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            timeFormat.format(now),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          // Weather Header (Icon, Temp, Location)
                          _buildWeatherHeader(context, weather),
                          
                          const SizedBox(height: 30),
                          
                          // Weather Details Card
                          _buildWeatherDetailsCard(context, weather),
                          
                          const SizedBox(height: 30),
                          
                          // City Search
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Search Location',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _cityController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter city name',
                                            prefixIcon: const Icon(Icons.search),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          textInputAction: TextInputAction.search,
                                          onSubmitted: (value) {
                                            if (value.isNotEmpty) {
                                              weatherProvider.fetchWeatherByCity(value);
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.my_location),
                                        onPressed: () {
                                          weatherProvider.fetchWeatherByCurrentLocation();
                                          _cityController.clear();
                                        },
                                        tooltip: 'Use current location',
                                        style: IconButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(26),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Weather App',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: themeProvider.isDarkMode ? Colors.orange : Colors.blueGrey,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: themeProvider.isDarkMode ? 'Light mode' : 'Dark mode',
          ),
        ],
      ),
    );
  }

  // Get appropriate background gradient based on weather and time of day
  LinearGradient _getBackgroundGradient(String weatherDescription, int hour, bool isDark) {
    final description = weatherDescription.toLowerCase();
    final isNight = hour < 6 || hour > 18;
    
    if (isDark) {
      // Dark mode gradients
      if (description.contains('rain') || description.contains('drizzle')) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
        );
      } else if (description.contains('cloud')) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2c3e50), Color(0xFF34495e)],
        );
      } else if (description.contains('clear')) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isNight 
              ? [const Color(0xFF0f2027), const Color(0xFF203a43)]
              : [const Color(0xFF2c3e50), const Color(0xFF4a69bd)],
        );
      } else if (description.contains('snow')) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2c3e50), Color(0xFF2980b9)],
        );
      } else {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F1F1F), Color(0xFF3E3E3E)],
        );
      }
    } else {
      // Light mode gradients
      if (description.contains('rain') || description.contains('drizzle')) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5D8CAE), Color(0xFF3498db)],
        );
      } else if (description.contains('cloud')) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9dc5f8), Color(0xFF76a8e7)],
        );
      } else if (description.contains('clear')) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isNight 
              ? [const Color(0xFF31429A), const Color(0xFF537895)]
              : [const Color(0xFF56CCF2), const Color(0xFF2F80ED)],
        );
      } else if (description.contains('snow')) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCFD9DF), Color(0xFFE2EBF0)],
        );
      } else {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF74ebd5), Color(0xFFACB6E5)],
        );
      }
    }
  }

  // Build Weather Header Widget
  Widget _buildWeatherHeader(BuildContext context, WeatherModel weather) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final size = MediaQuery.of(context).size;
    
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          // City Name
          Text(
            weather.cityName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          
          const SizedBox(height: 5),
          
          // Weather description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withAlpha(38)
                  : Colors.black.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              weather.description,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Weather Icon and Temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Image.network(
                  'https://openweathermap.org/img/wn/${weather.icon}@4x.png',
                  width: size.width * 0.35,
                  height: size.width * 0.35,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    _getWeatherIcon(weather.description),
                    size: 80,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.temperature.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 0.9,
                        ),
                      ),
                      Text(
                        '°C',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Feels like: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      Text(
                        '${weather.feelsLike.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Build Weather Details Card Widget
  Widget _buildWeatherDetailsCard(BuildContext context, WeatherModel weather) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetailItem(
                  context,
                  Icons.thermostat_outlined,
                  'Feels Like',
                  '${weather.feelsLike.toStringAsFixed(1)}°C',
                ),
                _buildWeatherDetailItem(
                  context,
                  Icons.air,
                  'Wind',
                  '${weather.windSpeed} m/s',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetailItem(
                  context,
                  Icons.water_drop_outlined,
                  'Humidity',
                  '${weather.humidity}%',
                ),
                _buildWeatherDetailItem(
                  context,
                  Icons.visibility_outlined,
                  'Pressure',
                  'N/A',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeatherDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    
    if (desc.contains('clear')) return Icons.wb_sunny;
    if (desc.contains('cloud')) return Icons.cloud;
    if (desc.contains('rain') || desc.contains('drizzle')) return Icons.grain;
    if (desc.contains('thunder')) return Icons.flash_on;
    if (desc.contains('snow')) return Icons.ac_unit;
    if (desc.contains('mist') || desc.contains('fog')) return Icons.cloud;
    
    return Icons.wb_sunny;
  }

  @override
  void dispose() {
    _cityController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}