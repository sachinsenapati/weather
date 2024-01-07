import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weather/models/city.dart';
import 'package:weather/models/constants.dart';
import 'package:http/http.dart' as http;
import 'package:weather/widgets/weateher_item.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Constants myConstants = Constants();

  int temp = 0;
  int maxTemp = 0;
  String weatherStateName = "loading";
  int humidity = 0;
  int windSpeed = 0;

  var currentDate = "Loading...";
  String imageUrl = "";
  String location = 'London';

  // Get the cities and selected cities data
  var selectedCities = City.getSelectedCities();
  List<String> cities = ['London'];

  List consolidateWeatherList = [];

  @override
  void initState() {
    fetchWeather(cities[0]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Image.asset(
                  'assets/profile.png',
                  width: 40,
                  height: 40,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/pin.png',
                    width: 20,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  DropdownButton(
                    value: location,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: cities.map((String location) {
                      return DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        location = newValue!;
                        fetchWeather(location);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            Text(
              currentDate,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 16),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              width: size.width,
              height: 200,
              decoration: BoxDecoration(
                  color: myConstants.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: myConstants.primaryColor.withOpacity(0.5),
                        offset: const Offset(0, 25),
                        blurRadius: 10,
                        spreadRadius: -12),
                  ]),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                      top: -40,
                      left: 20,
                      child: imageUrl == ''
                          ? const Text('')
                          : Image.network(
                              "http://openweathermap.org/img/wn/$imageUrl@2x.png",
                            )),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    child: Text(
                      weatherStateName,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  Positioned(
                      top: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              temp.toString(),
                              style: const TextStyle(
                                  fontSize: 80, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Text(
                            'o',
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          )
                        ],
                      ))
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WeatherItem(
                      text: 'Wind Speed',
                      value: windSpeed,
                      unit: ' km/h',
                      imageUri: 'assets/windspeed.png',
                    ),
                    WeatherItem(
                        text: 'Humidity',
                        value: humidity,
                        unit: '',
                        imageUri: 'assets/humidity.png'),
                    WeatherItem(
                        text: 'Temperature',
                        value: maxTemp,
                        unit: ' C',
                        imageUri: 'assets/max-temp.png')
                  ]),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  void fetchWeather(String location) async {
    final uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?appid=43b35819b268300f0f27f2ce39d38da3&q=$location&units=metric');
    final response = await http.get(uri);
    final result = jsonDecode(response.body) as Map;
    setState(() {
      location = result['name'] as String;
      temp = result['main']['temp'].round();
      maxTemp = result['main']['temp_max'].round();
      humidity = result['main']['humidity'].round();
      windSpeed = result['wind']['speed'].round();
      weatherStateName = result['weather'][0]['main'];
      imageUrl = result['weather'][0]['icon'];
    });
  }
}
