// import 'dart:developer';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:dio/dio.dart';

// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   final TextEditingController _controller = TextEditingController();
//   List<dynamic> _places = [];
//   final String _apiKey =
//       'AIzaSyBlOHHY5x8jzRcVIVs2NcLl-RdDZT6eXvE'; // Replace with your actual API key
//   LatLng? _selectedLocation; // To hold the selected location
//   GoogleMapController? _mapController; // To control the Google Map

//   Future<void> fetchSuggestions(String input) async {
//     if (input.isEmpty) return;

//     final String url =
//         'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey';

//     try {
//       final response = await Dio().get(url);
//       log('p response:$url');
//       log('p response: ${response.data}');
//       if (response.statusCode == 200) {
//         setState(() {
//           _places = response.data['predictions'];
//         });
//       } else {
//         log('Error: ${response.statusMessage}');
//       }
//     } catch (e) {
//       log("Error fetching suggestions: $e");
//     }
//   }

//   Future<void> fetchPlaceDetails(String placeId) async {
//     final String url =
//         'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey';

//     try {
//       final response = await Dio().get(url);
//       if (response.statusCode == 200) {
//         final location = response.data['result']['geometry']['location'];
//         final lat = location['lat'];
//         final lng = location['lng'];
//         log('Latitude: $lat, Longitude: $lng');
//         setState(() {
//           _selectedLocation = LatLng(lat, lng);
//         });

//         _mapController
//             ?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
//       } else {
//         log('Error: ${response.statusMessage}');
//       }
//     } catch (e) {
//       log("Error fetching place details: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Place Suggestion")),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: DropdownSearch<dynamic>(
//               popupProps: PopupProps.menu(
//                 showSearchBox: true,
//                 searchFieldProps: TextFieldProps(
//                   decoration: InputDecoration(
//                     hintText: "Search for a place",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
// items: (String? filter) async {
//   await fetchSuggestions(filter ?? '');
//   return _places;
// },
//               itemAsString: (item) => item['description'] as String,
//               compareFn: (item1, item2) =>
//                   item1['place_id'] == item2['place_id'], // Add this line
//               onChanged: (value) {
//                 if (value != null) {
//                   fetchPlaceDetails(value['place_id']); // Fetch details
//                 }
//               },
//             ),
//           ),
//           /*  Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: DropdownSearch<dynamic>(
//               popupProps: PopupProps.menu(
//                 showSearchBox: true,
//                 searchFieldProps: TextFieldProps(
//                   decoration: InputDecoration(
//                     hintText: "Search for a place",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               asyncItems: (String? filter) async {
//                 return await fetchSuggestions(filter ?? '');
//               },
//               itemAsString: (item) => item['description'] as String,
//               onChanged: (value) {
//                 if (value != null) {
//                   fetchPlaceDetails(value['place_id']); // Fetch details
//                 }
//               },
//               /*  dropdownDecoratorProps: DropDownDecoratorProps(
//                 dropdownSearchDecoration: InputDecoration(
//                   labelText: "Select a place",
//                   border: OutlineInputBorder(),
//                 ),
//               ),*/
//             ),
//           ),
//          */
//           Expanded(
//             child: Container(
//               height: 300,
//               color: Colors.indigo,
//               child: GoogleMap(
//                 onMapCreated: (GoogleMapController controller) {
//                   _mapController = controller; // Initialize the map controller
//                 },
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(0, 0), // Default position
//                   zoom: 2, // Default zoom level
//                 ),
//                 markers: _selectedLocation != null
//                     ? {
//                         Marker(
//                           markerId: MarkerId('selectedPlace'),
//                           position: _selectedLocation!,
//                         ),
//                       }
//                     : {},
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
