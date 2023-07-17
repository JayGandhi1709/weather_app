import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/widgets/additional_information_item.dart';
import 'package:weather_app/widgets/houlry_forecast_item.dart';
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  Future<Map<String, dynamic>> getCurrentWeather() async {
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
    weather = getCurrentWeather();
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
            onPressed: (){
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
          future: weather,
          builder: (context, snapshot) {
            print(snapshot);
            print(snapshot.runtimeType);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final data = snapshot.data!;

            final currentWeatherData = data['list'][0];

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
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_pin),
                          Text(data['city']['name']),
                        ],
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
                                        fontSize: 32),
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
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     children: [
                    //       for(int i = 1;i < 5;i++)
                    //         HourlyForecastItem(
                    //           time: data['list'][i+1]['dt_txt'].toString(),
                    //           img: data['list'][i+1]['weather'][0]['icon'].toString(),
                    //           // icon: Icons.cloud,
                    //           temperature: data['list'][i+1]['main']['temp'].toString(),
                    //         )
                    //     ],
                    //   ),
                    // ),

                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int i) {
                          final hourlyForcast = data['list'][i + 1];
                          final time = DateTime.parse(hourlyForcast['dt_txt']);

                          return HourlyForecastItem(
                            time: DateFormat.j().format(time).toString(),
                            // img: hourlyForcast['weather'][0]['icon'].toString(),
                            icon: Icons.cloud,
                            temperature:
                                "${hourlyForcast['main']['temp'].round().toString()}°C",
                          );
                        },
                      ),
                    ),
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
