import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/components/additional_information.dart';
import 'package:weather_app/components/secrets.dart';
import 'package:weather_app/components/weather_forcasting_card.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController textEditingController = TextEditingController();
  double temp = 0;
  String name = 'Coimbatore';
  Future<Map<String, dynamic>> getWeather() async {
    try {
      final cityName = name;
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apikey',
        ),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                name = 'Coimbatore';
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      //geting the values from the json file
      body: FutureBuilder(
        future: getWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final data = snapshot.data!;
          final maindata = data['list'][0];
          final double temp = maindata['main']['temp'];
          final int currentTemp = (temp - 273.15).ceil();
          final currentSky = maindata['weather'][0]['main'];
          final currentPressure = maindata['main']['pressure'];
          final currentSpeed = maindata['wind']['speed'];
          final currentHumidity = maindata['main']['humidity'];
          String hint = 'Enter a city name';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Input for the cityname
                SizedBox(
                  width: double.infinity,
                  child: TextField(
                    controller: textEditingController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: hint,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(13),
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 58, 58, 58),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(13),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 58, 58, 58)),
                        borderRadius: BorderRadius.all(
                          Radius.circular(13),
                        ),
                      ),
                      focusColor: const Color.fromARGB(255, 58, 58, 58),
                      suffixIcon: GestureDetector(
                        child: const Icon(Icons.search),
                        onTap: () {
                          setState(() {
                            name = textEditingController.text;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    //Main card
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          //temperature
                          Text(
                            '$currentTemp °C',
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          //cloud icon
                          Icon(
                            currentSky == 'Rain' || currentSky == 'Clouds'
                                ? Icons.cloud
                                : Icons.sunny,
                            size: 60,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          //weather now
                          Text(
                            currentSky,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Hourly Forcasting',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 9,
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final double hourlytemp = hourlyForecast['main']['temp'];
                      final int hrtemp = (hourlytemp - 273.15).ceil();
                      final time =
                          DateTime.parse(hourlyForecast['dt_txt'].toString());
                      return WeatherForcastingCard(
                        time: DateFormat.j().format(time),
                        icon: hourlyForecast['weather'][0]['main'] == 'Rain' ||
                                hourlyForecast['weather'][0]['main'] == 'Clouds'
                            ? Icons.cloud
                            : Icons.sunny,
                        temperature: '$hrtemp °C',
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Additional Information',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AdditionalInformation(
                          icon: Icons.water_drop,
                          currentStage: 'Humidity',
                          level: currentHumidity.toString(),
                        ),
                        AdditionalInformation(
                          icon: Icons.air,
                          currentStage: 'Speed',
                          level: currentSpeed.toString(),
                        ),
                        AdditionalInformation(
                          icon: Icons.beach_access,
                          currentStage: 'Pressure',
                          level: currentPressure.toString(),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
