import 'package:geolocator/geolocator.dart';

class LocationService {
  // Function to check and request location permissions
  static Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    // Check for permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permission permanently denied. Please enable it in settings.");
    }

    return true;
  }

  // Function to get current user location
  static Future<Position> getCurrentLocation() async {
    bool hasPermission = await requestPermission();
    if (hasPermission) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    }
    throw Exception("Location permission not granted");
  }
}
