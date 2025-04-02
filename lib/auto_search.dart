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
/*DropdownSearch<String>(
  popupProps: PopupProps.menu(showSearchBox: true),
        mode: Mode.custom,
           items: _places.map((place) => place['description'] as String).toList(),
        onChanged: (value) {
          // Handle the selected value
          print("Selected place: $value");
        },
        dropdownBuilder: (context, selectedItem) {
          return Text(selectedItem ?? "Select a place");
        },
        filterFn: (item, filter) => item.toLowerCase().contains(filter.toLowerCase()),
        onFind: (String filter) async {
          await fetchSuggestions(filter);
          return _places.map((place) => place['description'] as String).toList();
        },
      ),*/

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
