import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/theme_provider.dart';

class WeatherHeader extends StatelessWidget {
  final WeatherModel weather;
  
  const WeatherHeader({
    Key? key,
    required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  ? Colors.white.withOpacity(0.15)
                  : Colors.black.withOpacity(0.1),
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
                        '${weather.temperature.toStringAsFixed(0)}',
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
}