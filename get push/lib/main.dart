import 'package:flutter/material.dart';
import 'model/weather.dart';
import 'repository/weather_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({Key? key}) : super(key: key);

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherRepository repository = WeatherRepository();
  List<Weather> weatherList = [];
  bool isLoading = false;
  final TextEditingController cityController = TextEditingController();

  // Pre-defined cities to fetch on load
  final List<String> defaultCities = ['London', 'Lagos', 'New York', 'Tokyo', 'Paris'];

  @override
  void initState() {
    super.initState();
    fetchMultipleWeathers();
  }

  Future<void> fetchMultipleWeathers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final weathers = await repository.fetchWeatherForMultipleCities(defaultCities);
      setState(() {
        weatherList = weathers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> searchWeather() async {
    if (cityController.text.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final weather = await repository.fetchWeather(cityController.text);
      setState(() {
        weatherList.insert(0, weather);
        isLoading = false;
      });
      cityController.clear();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('City not found or error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchMultipleWeathers,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      hintText: 'Enter city name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => searchWeather(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: searchWeather,
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : weatherList.isEmpty
                    ? const Center(child: Text('No weather data'))
                    : ListView.builder(
                        itemCount: weatherList.length,
                        itemBuilder: (context, index) {
                          final weather = weatherList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: Image.network(
                                'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                                width: 50,
                                height: 50,
                              ),
                              title: Text(
                                weather.cityName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${weather.temperature.toStringAsFixed(1)}°C - ${weather.description}',
                                  ),
                                  Text(
                                    'Feels like: ${weather.feelsLike.toStringAsFixed(1)}°C',
                                  ),
                                  Text(
                                    'Humidity: ${weather.humidity}% | Wind: ${weather.windSpeed} m/s',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }
}