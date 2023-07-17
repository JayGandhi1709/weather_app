import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/screens/search_screen.dart';
import 'package:weather_app/widgets/additional_information_item.dart';
import 'package:weather_app/widgets/houlry_forecast_item.dart';
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> currentWeather;
  late Future<Map<String, dynamic>> forecastWeather;

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = "Vadodara";
      String units = "metric";

      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&APPID=$openWeatherAPIKey&units=$units',
        ),
      );
      // print(res.body);

      final data = jsonDecode(res.body);

      if (data['cod'] != 200) {
        throw "An unexpected error occure";
        // throw data['message'];
      }
      // print(data['list'][0]['main']['temp']);

      // temp = data['list'][0]['main']['temp'];

      // temp = data['list'][0]['main']['temp'] - 273.15;
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getForecastWeather() async {
    try {
      String cityName = "Vadodara";
      String units = "metric";

      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey&units=$units',
        ),
      );
      // print(res.body);

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw "An unexpected error occure";
        // throw data['message'];
      }
      // print(data['list'][0]['main']['temp']);

      // temp = data['list'][0]['main']['temp'];

      // temp = data['list'][0]['main']['temp'] - 273.15;
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentWeather = getCurrentWeather();
    forecastWeather = getForecastWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                currentWeather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
          future: currentWeather,
          builder: (context, snapshot) {
            // print(snapshot);
            // print(snapshot.runtimeType);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final currentWeatherData = snapshot.data!;

            // final currentWeatherData = data['list'][0];

            final currentTemp = currentWeatherData['main']['temp'];
            final currentIcon = currentWeatherData['weather'][0]['icon'];
            final currentSky = currentWeatherData['weather'][0]['main'];
            final currentHumidity = currentWeatherData['main']['humidity'];
            final currentWindSpeed = currentWeatherData['wind']['speed'];
            final currentPressure = currentWeatherData['main']['pressure'];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return const SearchScreen();
                          },
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_pin),
                            Text(currentWeatherData['name']),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  // °C
                                  Text(
                                    "${currentTemp.round().toString()}°C",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                  ),
                                  // const SizedBox(height: 16),
                                  // Icon(
                                  //     currentSky == "clouds"
                                  //         ? Icons.cloud
                                  //         : currentSky == "Rain"
                                  //             ? CupertinoIcons.cloud_rain_fill
                                  //             : Icons.sunny,
                                  //     size: 64),
                                  // const SizedBox(height: 16),
                                  Image.network(
                                    "https://openweathermap.org/img/wn/$currentIcon@2x.png",
                                    width: 100,
                                  ),
                                  Text(
                                    "$currentSky",
                                    style: const TextStyle(fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Weather Forcast card
                    const Text(
                      "Hourly Forecast",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),

                    FutureBuilder(
                        future: forecastWeather,
                        builder: (context, snapshot) {
                          // print(snapshot);
                          // print(snapshot.runtimeType);
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator.adaptive());
                          }

                          if (snapshot.hasError) {
                            return Center(
                                child: Text(snapshot.error.toString()));
                          }
                          final forecastWeatherData = snapshot.data!;

                          // print("Hello : ${forecastWeatherData.toString()}");

                          // final forecastWeather =
                          //     forecastWeatherData['list'][0];

                          // final forecastTemp = forecastWeather['main']['temp'];
                          // final forecastIcon =
                          //     forecastWeather['weather'][0]['icon'];

                          return SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              // itemCount: data.length,
                              itemCount: forecastWeatherData.length,
                              itemBuilder: (BuildContext context, int i) {
                                final hourlyForcast =
                                    forecastWeatherData['list'][i + 1];
                                final time =
                                    DateTime.parse(hourlyForcast['dt_txt']);

                                return HourlyForecastItem(
                                  time: DateFormat.j().format(time).toString(),
                                  // img: hourlyForcast['weather'][0]['icon'].toString(),
                                  icon: Icons.cloud,
                                  temperature:
                                      "${hourlyForcast['main']['temp'].round().toString()}°C",
                                );
                              },
                            ),
                          );
                        }),
                    const SizedBox(height: 20),

                    // Additional Information card
                    const Text(
                      "Additional Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInformationItem(
                          icon: Icons.water_drop,
                          label: "humidity",
                          value: "$currentHumidity%",
                        ),
                        AdditionalInformationItem(
                          icon: Icons.air,
                          label: "Wind Speed",
                          value: "$currentWindSpeed",
                        ),
                        AdditionalInformationItem(
                          icon: Icons.beach_access,
                          label: "Pressure",
                          value: "$currentPressure",
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
