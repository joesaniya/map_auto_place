import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_example/auto_search.dart';
import 'package:map_example/service/location_service.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _locationMessage = "Fetching location...";
  String _selectedLocationMessage = "";

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    log('calling _getUserLocation');
    try {
      Position position = await LocationService.getCurrentLocation();
      setState(() {
        _locationMessage =
            "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        _locationMessage = "Error: $e";
      });
    }
    log('message:$_locationMessage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Get User Location")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_selectedLocationMessage ?? _locationMessage,
                textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              /*   onPressed: () async {
                // Navigate to AutoSearchPage and wait for the result
                final selectedLocation = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AutoSearchPage()),
                );

                log('previous location: $_selectedLocationMessage');
                if (selectedLocation != null) {
                  // Extracting the relevant information from the selected location
                  String description = selectedLocation['description'];
                  String placeId = selectedLocation['place_id'];

                  setState(() {
                    _selectedLocationMessage =
                        "Selected: $description, Place ID: $placeId";
                  });
                }
              },
            */
              onPressed: () async {
                final selectedLocation = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AutoSearchPage()),
                );

                log('previous location: $_selectedLocationMessage');

                if (selectedLocation != null &&
                    selectedLocation is Map<String, dynamic>) {
                  String? description =
                      selectedLocation['description'] as String?;
                  String? placeId = selectedLocation['place_id'] as String?;

                  setState(() {
                    _selectedLocationMessage =
                        "Selected latitude: ${selectedLocation['latitude']}, longitude: ${selectedLocation['longitude']}";
                    /*   _selectedLocationMessage =
                        "Selected: ${description ?? 'Unknown'}, Place ID: ${placeId ?? 'Unknown'},latitude: ${selectedLocation['latitude']}, longitude: ${selectedLocation['longitude']}";
                 */
                  });
                } else {
                  log('No location selected or invalid data received.');
                }
              },
              child: Text("Get Location"),
            ),
            SizedBox(height: 20),
            // Display the selected location message if available
            if (_selectedLocationMessage.isNotEmpty)
              Text(_selectedLocationMessage, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
