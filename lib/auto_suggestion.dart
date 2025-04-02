import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';

class PlaceSuggestionPage1 extends StatefulWidget {
  @override
  _PlaceSuggestionPageState1 createState() => _PlaceSuggestionPageState1();
}

class _PlaceSuggestionPageState1 extends State<PlaceSuggestionPage1> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _places = [];
  final String _apiKey =
      'AIzaSyBlOHHY5x8jzRcVIVs2NcLl-RdDZT6eXvE'; // Replace with your actual API key

  Future<void> fetchSuggestions(String input) async {
    if (input.isEmpty) return;

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey';

    try {
      final response = await Dio().get(url);
      log('p response:$url');
      log('p response: ${response.data}');
      if (response.statusCode == 200) {
        setState(() {
          _places = response.data['predictions'];
        });
      } else {
        log('Error: ${response.statusMessage}');
      }
    } catch (e) {
      log("Error fetching suggestions: $e");
    }
  }

  Future<void> fetchPlaceDetails(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final location = response.data['result']['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        log('Latitude: $lat, Longitude: $lng');
        // Display lat and lng as needed
      } else {
        log('Error: ${response.statusMessage}');
      }
    } catch (e) {
      log("Error fetching place details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Place Suggestion")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search for a place',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                if (text.isNotEmpty) {
                  fetchSuggestions(text);
                } else {
                  setState(() {
                    _places.clear();
                  });
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _places.length,
                itemBuilder: (context, index) {
                  final place = _places[index];
                  return ListTile(
                    title: Text(place['description']),
                    onTap: () {
                      _controller.text = place['description'];
                      fetchPlaceDetails(place['place_id']);
                      setState(() {
                        _places.clear(); // Clear suggestions after selection
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceSuggestionPage extends StatefulWidget {
  @override
  _PlaceSuggestionPageState createState() => _PlaceSuggestionPageState();
}

class _PlaceSuggestionPageState extends State<PlaceSuggestionPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _places = [];
  final String _apiKey = 'AIzaSyBlOHHY5x8jzRcVIVs2NcLl-RdDZT6eXvE';
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  Future<void> fetchSuggestions(String input) async {
    if (input.isEmpty) return;

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey';

    try {
      final response = await Dio().get(url);
      log('p response:$url');
      log('p response: ${response.data}');
      if (response.statusCode == 200) {
        setState(() {
          _places = response.data['predictions'];
        });
      } else {
        log('Error: ${response.statusMessage}');
      }
    } catch (e) {
      log("Error fetching suggestions: $e");
    }
  }

  Future<void> fetchPlaceDetails(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final location = response.data['result']['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        log('Latitude: $lat, Longitude: $lng');
        setState(() {
          _selectedLocation = LatLng(lat, lng);
        });

        _mapController
            ?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
      } else {
        log('Error: ${response.statusMessage}');
      }
    } catch (e) {
      log("Error fetching place details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Place Suggestion")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search for a place',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                if (text.isNotEmpty) {
                  fetchSuggestions(text);
                } else {
                  setState(() {
                    _places.clear();
                  });
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _places.length,
              itemBuilder: (context, index) {
                final place = _places[index];
                return ListTile(
                  title: Text(place['description']),
                  onTap: () {
                    _controller.text = place['description']; // Update TextField
                    fetchPlaceDetails(place['place_id']); // Fetch details
                    setState(() {
                      _places.clear(); // Clear suggestions after selection
                    });
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
          Container(
            height: 300,
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller; // Initialize the map controller
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(0, 0), // Default position
                zoom: 2, // Default zoom level
              ),
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: MarkerId('selectedPlace'),
                        position: _selectedLocation!,
                      ),
                    }
                  : {},
            ),
          ),
        ],
      ),
    );
  }
}
/*import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:dio/dio.dart';

class PlaceSuggestionPage extends StatefulWidget {
  @override
  _PlaceSuggestionPageState createState() => _PlaceSuggestionPageState();
}

class _PlaceSuggestionPageState extends State<PlaceSuggestionPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _places = [];
  final String _apiKey = 'AIzaSyBlOHHY5x8jzRcVIVs2NcLl-RdDZT6eXvE';

  Future<void> fetchSuggestionsold(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey';

    try {
      final response = await Dio().get(url);
      log('response: ${response.data}');
      setState(() {
        _places = response.data['predictions'];
      });
    } catch (e) {
      log("Error fetching suggestions: $e");
    }
  }

  Future<void> fetchSuggestions(String input) async {
    if (input.isEmpty) return;

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey';

    try {
      final response = await Dio().get(url);
      log('p response:$url');
      log('p response: ${response.data}');
      if (response.statusCode == 200) {
        log('Response: ${response.data}');
        setState(() {
          _places = response.data['predictions'];
        });
      } else {
        log('Error: ${response.statusMessage}');
      }
    } catch (e) {
      log("Error fetching suggestions: $e");
    }
  }

  Future<void> fetchSuggestions1(String input) async {
    if (input.isEmpty) return;

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey';

    try {
      final response = await Dio().get(url);

      if (response.statusCode == 200) {
        log('Response: ${response.data}');
        setState(() {
          _places = response.data['predictions'];
        });
      } else {
        log('Error: ${response.statusMessage}');
      }
    } catch (e) {
      log("Error fetching suggestions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Place Suggestion")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search for a place',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                if (text.isNotEmpty) {
                  fetchSuggestions(text);
                } else {
                  setState(() {
                    _places.clear();
                  });
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _places.length,
                itemBuilder: (context, index) {
                  final place = _places[index];
                  return ListTile(
                    title: Text(place['description']),
                    onTap: () {
                      // Do something when a place is tapped, e.g., show it on a map
                      print('Selected Place: ${place['description']}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/