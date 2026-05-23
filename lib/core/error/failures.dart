import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class BookingFailure extends Failure {
  const BookingFailure(super.message);
}

class PaymentFailure extends Failure {
  const PaymentFailure(super.message);
}

class LocationFailure extends Failure {
  const LocationFailure(super.message);
}
