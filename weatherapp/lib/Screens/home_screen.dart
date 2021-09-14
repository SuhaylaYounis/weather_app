import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weatherapp/models/tempmodel.dart';

class home_screen extends StatefulWidget {
  const home_screen({Key? key}) : super(key: key);

  @override
  _home_screenState createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  int temperature = 0;
  int woeid = 0;
  String city = "City";
  String weather = "clear";
  String abbr = "c";

//method to get the city name
  Future<void> fetchCity(String input) async {
    var url = Uri.parse(
        'https://www.metaweather.com/api/location/search/?query=$input');
    var response = await http.get(url);
    var responsebody = jsonDecode(response.body)[0];
    setState(() {
      woeid = responsebody["woeid"];
      city = responsebody["title"];
    });
  }

  //method to get the city temperature
  Future<List<tempmodel>> fetchTemperature() async {
    var url = Uri.parse('https://www.metaweather.com/api/location/$woeid');
    var response = await http.get(url);
    var responsebody = jsonDecode(response.body)["consolidated_weather"];
    setState(() {
      temperature = responsebody[0]["the_temp"].round();
      print(temperature);
      weather = responsebody[0]["weather_state_name"]
          .replaceAll(" ", "")
          .tolowercase();
      print(weather);
      abbr = responsebody[0]["weather_state_abbr"];
    });
    List<tempmodel> list = [];
    for (var i in responsebody) {
      tempmodel x = tempmodel(
          applicable_date: i["applicable_date"],
          max_temp: i["max_temp"],
          min_temp: i["min_temp"],
          weather_state_abbr: i["weather_state_abbr"]);
      list.add(x);
      print(list);
    }
    return list;
  }

  //method toi call city and temp methods
  Future<void> onTextFeildSubmit(String input) async {
    await fetchCity(input);
    await fetchTemperature();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("images/${weather}.png"),
        fit: BoxFit.cover,
      )),
      child: Scaffold(
        //to avoid overriding of pixels
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: ListView(scrollDirection: Axis.vertical, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //for the city names
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        "$city",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 50.0,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                  //for the city condition icon
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Image.network(
                        "https://www.metaweather.com/static/img/weather/png/$abbr.png",
                        alignment: Alignment.topCenter,
                        height: 200,
                        width: 200,
                      ),
                    ),
                  ),

                  // for the city temperature
                  Padding(
                    padding: const EdgeInsets.only(top:10.0,left:30.0),
                    child: Center(
                      child: Text(
                        "$temperature °",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 70.0,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              //for the search bar
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      onSubmitted: (String input) {
                        print("$input");
                        onTextFeildSubmit(input);
                      },
                      style: const TextStyle(
                          fontStyle: FontStyle.normal, fontSize: 20.0),
                      decoration: const InputDecoration(
                        hintText: "search location",
                        hintStyle: TextStyle(
                          fontSize: 18,
                        ),
                        prefixIcon: Icon(Icons.search_outlined),
                      ),
                    ),
                  ),
                  Container(
                    height: 170,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 20.0),
                    child: FutureBuilder(
                      future: fetchTemperature(),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.length,
                            itemBuilder: ( context, index) {
                              return Card(
                                color: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Container(
                                  height: 170,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Date:${snapshot.data[index].applicable_data}",
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                      Image.network(
                                        "https://www.metaweather.com/static/img/weather/png/${snapshot.data[index].weather_state_abbr}.png",
                                        alignment: Alignment.topCenter,
                                        height: 50,
                                        width: 200,
                                      ),
                                      Text(
                                        "Min:${snapshot.data[index].min_temp.round()}",
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        "Max:${snapshot.data[index].max_temp.round()}",
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        "Date:${snapshot.data[index].applicable_data}",
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Text(" nullll");
                        }
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
