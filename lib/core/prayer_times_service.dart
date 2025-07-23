import 'package:adhan_dart/adhan_dart.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimesService {
  static Future<PrayerTimes?> getPrayerTimes() async {
    // Request location permission and get current position
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Set calculation parameters (choose your method)
    final params = CalculationMethod.muslimWorldLeague();
    params.madhab = Madhab.shafi;

    // Get today's date
    final date = DateTime.now();

    // Create Coordinates object
    final coordinates = Coordinates(position.latitude, position.longitude);

    // Calculate prayer times
    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
    );

    return prayerTimes;
  }
} 