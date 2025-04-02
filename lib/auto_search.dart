import 'dart:developer';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';

class AutoSearchPage extends StatefulWidget {
  @override
  _AutoSearchPageState createState() => _AutoSearchPageState();
}

class _AutoSearchPageState extends State<AutoSearchPage> {
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

  double? lat, lng;
  Future<void> fetchPlaceDetails(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final location = response.data['result']['geometry']['location'];

        lat = location['lat'];
        lng = location['lng'];
        log('value: $lat,$lng');

        _selectedLocation = LatLng(lat!, lng!);

        log('selected location init: $_selectedLocation');
        _mapController
            ?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));

        log('selected location init2: $_selectedLocation');
      } else {
        log('Error: ${response.statusMessage}');
      }
    } catch (e) {
      log("Error fetching place details: $e");
    }
  }

  /*double? lat, lng;
  Future<void> fetchPlaceDetails(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final location = response.data['result']['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];
        /*  lat = location['lat'];
        lng = location['lng'];*/
        log('value: $lat,$lng');
        if (mounted) {
          setState(() {
            _selectedLocation = LatLng(lat!, lng!);
          });
          log('selected location init: $_selectedLocation');
          _mapController
              ?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
        }
        log('selected location init2: $_selectedLocation');
      } else {
        log('Error: ${response.statusMessage}');
      }
    } catch (e) {
      log("Error fetching place details: $e");
    }
  }
*/
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
                  onTap: () async {
                    final selectedPlace = place;
                    _controller.text = selectedPlace['description'];

                    await fetchPlaceDetails(selectedPlace['place_id']);

                    if (_selectedLocation != null) {
                      Navigator.pop(context, {
                        'description': selectedPlace['description'],
                        'place_id': selectedPlace['place_id'],
                        'latitude': _selectedLocation!.latitude,
                        'longitude': _selectedLocation!.longitude,
                      });
                    } else {
                      log('Error: _selectedLocation is null');
                    }

                    setState(() {
                      _places.clear();
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
