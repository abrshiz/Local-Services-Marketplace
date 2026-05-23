abstract class LocationRepository {
  Future<({double latitude, double longitude})> getCurrentPosition();
  Future<bool> requestPermission();
}
