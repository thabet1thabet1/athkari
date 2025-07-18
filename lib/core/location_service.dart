import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _locationPermissionKey = 'location_permission_granted';
  static const String _lastKnownCityKey = 'last_known_city';
  static const String _lastKnownLatKey = 'last_known_lat';
  static const String _lastKnownLngKey = 'last_known_lng';

  // Check if location permission was previously granted
  static Future<bool> wasLocationPermissionGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationPermissionKey) ?? false;
  }

  // Save location permission status
  static Future<void> saveLocationPermissionStatus(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationPermissionKey, granted);
  }

  // Save last known location
  static Future<void> saveLastKnownLocation(String city, double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastKnownCityKey, city);
    await prefs.setDouble(_lastKnownLatKey, lat);
    await prefs.setDouble(_lastKnownLngKey, lng);
  }

  // Get last known location
  static Future<Map<String, dynamic>?> getLastKnownLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString(_lastKnownCityKey);
    final lat = prefs.getDouble(_lastKnownLatKey);
    final lng = prefs.getDouble(_lastKnownLngKey);
    
    if (city != null && lat != null && lng != null) {
      return {
        'city': city,
        'lat': lat,
        'lng': lng,
      };
    }
    return null;
  }

  // Request location permission and get current location
  static Future<Map<String, dynamic>?> getCurrentLocation({bool forceRequest = false}) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      // If permission is denied and we should force request, or if permission was never requested
      if (permission == LocationPermission.denied && forceRequest) {
        permission = await Geolocator.requestPermission();
        await saveLocationPermissionStatus(permission == LocationPermission.whileInUse || 
                                         permission == LocationPermission.always);
        
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return null;
        }
      }

      // If permission is permanently denied, return null
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // If permission is denied and we're not forcing request, return last known location
      if (permission == LocationPermission.denied && !forceRequest) {
        return await getLastKnownLocation();
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get city name with better accuracy
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      String city = 'Unknown';
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Try to get the most specific city name available
        city = placemark.locality ?? 
               placemark.subLocality ?? 
               placemark.subAdministrativeArea ?? 
               placemark.administrativeArea ?? 
               'Unknown';
        
        // Add country for better identification if city is generic
        if (placemark.country != null && 
            (city == 'Unknown' || city.length < 3 || 
             city.toLowerCase() == placemark.country!.toLowerCase())) {
          city = '${placemark.locality ?? placemark.subAdministrativeArea ?? placemark.administrativeArea ?? 'Unknown'}, ${placemark.country}';
        }
      }

      // Save the location
      await saveLastKnownLocation(city, position.latitude, position.longitude);
      await saveLocationPermissionStatus(true);

      return {
        'city': city,
        'lat': position.latitude,
        'lng': position.longitude,
      };
    } catch (e) {
      // If getting current location fails, try to return last known location
      return await getLastKnownLocation();
    }
  }

  // Check if location permission is permanently denied
  static Future<bool> isLocationPermissionPermanentlyDenied() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.deniedForever;
  }

  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
} 