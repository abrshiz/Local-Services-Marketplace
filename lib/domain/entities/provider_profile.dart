import 'package:equatable/equatable.dart';
import 'package:localservicemarket/domain/entities/service.dart';
import 'package:localservicemarket/domain/entities/user.dart';

class ProviderProfile extends Equatable {
  const ProviderProfile({
    required this.provider,
    required this.services,
    required this.reviewCount,
  });

  final ServiceProvider provider;
  final List<Service> services;
  final int reviewCount;

  @override
  List<Object?> get props => [provider, services, reviewCount];
}
