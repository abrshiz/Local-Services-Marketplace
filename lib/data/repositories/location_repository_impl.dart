import 'package:geolocator/geolocator.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  @override
  Future<bool> requestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<({double latitude, double longitude})> getCurrentPosition() async {
    final granted = await requestPermission();
    if (!granted) {
      throw const LocationFailure('Location permission denied');
    }
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationFailure('Location services are disabled');
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return (latitude: pos.latitude, longitude: pos.longitude);
  }
}
