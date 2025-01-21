import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';

class WeatherService {
  Future<WeatherModel> getWeatherByCity(String city) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}