import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  WeatherModel? _weatherData;
  bool _isLoading = false;
  String? _error;

  WeatherModel? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final WeatherService _weatherService = WeatherService();

  Future<void> fetchWeatherByCity(String city) async {
    _setLoading(true);
    try {
      final weather = await _weatherService.getWeatherByCity(city);
      _setWeatherData(weather);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchWeatherByCurrentLocation() async {
    _setLoading(true);
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setError('Location permissions are denied');
          return;
        }
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      final weather = await _weatherService.getWeatherByLocation(
        position.latitude, 
        position.longitude
      );
      _setWeatherData(weather);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setWeatherData(WeatherModel weather) {
    _weatherData = weather;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}