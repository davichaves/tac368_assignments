// API Homework

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// Base URL: https://developer.nps.gov/api/v1/ extra: alerts?parkCode=acad,dena
// API Key: GaoOxCtKftlJc1uqVkYvBRymxQi0OOXMMHa9V5cM

class Park {
  final String name;
  final String code;

  Park(this.name, this.code);
}

class InfoState {
  List<Park> parks;
  String selectedState;

  Map<String, String> states = {
    "AL": "Alabama",
    "AK": "Alaska",
    "AZ": "Arizona",
    "AR": "Arkansas",
    "CA": "California",
    "CO": "Colorado",
    "CT": "Connecticut",
    "DE": "Delaware",
    "FL": "Florida",
    "GA": "Georgia",
    "HI": "Hawaii",
    "ID": "Idaho",
    "IL": "Illinois",
    "IN": "Indiana",
    "IA": "Iowa",
    "KS": "Kansas",
    "KY": "Kentucky",
    "LA": "Louisiana",
    "ME": "Maine",
    "MD": "Maryland",
    "MA": "Massachusetts",
    "MI": "Michigan",
    "MN": "Minnesota",
    "MS": "Mississippi",
    "MO": "Missouri",
    "MT": "Montana",
    "NE": "Nebraska",
    "NV": "Nevada",
    "NH": "New Hampshire",
    "NJ": "New Jersey",
    "NM": "New Mexico",
    "NY": "New York",
    "NC": "North Carolina",
    "ND": "North Dakota",
    "OH": "Ohio",
    "OK": "Oklahoma",
    "OR": "Oregon",
    "PA": "Pennsylvania",
    "RI": "Rhode Island",
    "SC": "South Carolina",
    "SD": "South Dakota",
    "TN": "Tennessee",
    "TX": "Texas",
    "UT": "Utah",
    "VT": "Vermont",
    "VA": "Virginia",
    "WA": "Washington",
    "WV": "West Virginia",
    "WI": "Wisconsin",
    "WY": "Wyoming",
  };

  InfoState(this.parks, this.selectedState);
}

class InfoCubit extends Cubit<InfoState> {
  InfoCubit() : super(InfoState([], "Select a State"));

  void update(List<Park> parks, String selectedState) {
    emit(InfoState(parks, selectedState));
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider<InfoCubit>(
        create: (context) => InfoCubit(),
        child: BlocBuilder<InfoCubit, InfoState>(
          builder: (context, state) => MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    InfoCubit myCubit = BlocProvider.of<InfoCubit>(context);
    InfoState state = myCubit.state;

    return Scaffold(
      appBar: AppBar(title: Text("Get National Parks by State")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              DropdownButton(
                items: state.states.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (String? value) async {
                  List<Park> parks = await _networkCall(value!);
                  await Future.delayed(Duration(milliseconds: 200));
                  myCubit.update(parks, state.states[value]!);
                },
                hint: Text(state.selectedState),
              ),
              for (Park park in state.parks)
                ListTile(
                  title: Text(park.name),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CampgroundsScreen(park: park),
                        ),
                      );
                    },
                    child: Text("show campgrounds"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Park>> _networkCall(String stateCode) async {
    final url = Uri.parse(
      'https://developer.nps.gov/api/v1/parks?stateCode=${stateCode}&api_key=GaoOxCtKftlJc1uqVkYvBRymxQi0OOXMMHa9V5cM',
    );
    final response = await http.get(url);
    Map<String, dynamic> dataAsMap = jsonDecode(response.body);
    // print(dataAsMap);
    List<dynamic> dataFields = dataAsMap['data'];

    List<Park> parks = [];
    for (int i = 0; i < dataFields.length; i++) {
      parks.add(Park(dataFields[i]['fullName'], dataFields[i]['parkCode']));
    }

    return parks;
  }
}

class CampgroundsScreen extends StatelessWidget {
  final Park park;
  const CampgroundsScreen({super.key, required this.park});

  Future<List<String>> _getCampgrounds() async {
    final url = Uri.parse(
      'https://developer.nps.gov/api/v1/campgrounds?parkCode=${park.code}&api_key=GaoOxCtKftlJc1uqVkYvBRymxQi0OOXMMHa9V5cM',
    );
    final response = await http.get(url);
    Map<String, dynamic> dataAsMap = jsonDecode(response.body);
    List<dynamic> dataFields = dataAsMap['data'];

    List<String> campgroundNames = [];
    for (int i = 0; i < dataFields.length; i++) {
      campgroundNames.add(dataFields[i]['name']);
    }
    return campgroundNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${park.name} Campgrounds")),
      body: FutureBuilder<List<String>>(
        future: _getCampgrounds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No campgrounds found."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(snapshot.data![index]));
            },
          );
        },
      ),
    );
  }
}
