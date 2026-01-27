import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/weather.dart';

class WeatherRepository {
  final String baseUrl = "https://api.openweathermap.org/data/2.5";
  final String apiKey = "dac413a5a5a6bc2267ff4b539a00608c"; 
  Future<Weather> fetchWeather(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl/weather?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load weather data");
    }
  }

  Future<List<Weather>> fetchWeatherForMultipleCities(List<String> cities) async {
    List<Weather> weatherList = [];
    
    for (String city in cities) {
      try {
        final weather = await fetchWeather(city);
        weatherList.add(weather);
      } catch (e) {
        print("Error fetching weather for $city: $e");
      }
    }
    
    return weatherList;
  }
}