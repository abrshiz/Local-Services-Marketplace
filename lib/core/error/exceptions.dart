class ServerException implements Exception {
  ServerException(this.message);
  final String message;
}

class CacheException implements Exception {
  CacheException(this.message);
  final String message;
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
}

class BookingException implements Exception {
  BookingException(this.message);
  final String message;
}

class PaymentException implements Exception {
  PaymentException(this.message);
  final String message;
}

class SlotUnavailableException implements Exception {
  SlotUnavailableException(this.message);
  final String message;
}

class ProviderUnavailableException implements Exception {
  ProviderUnavailableException(this.message);
  final String message;
}
