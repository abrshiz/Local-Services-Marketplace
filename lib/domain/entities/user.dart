import 'package:equatable/equatable.dart';
import 'package:localservicemarket/domain/entities/address.dart';
import 'package:localservicemarket/domain/entities/service_category.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';

abstract class User extends Equatable {
  const User({
    required this.userId,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String name;
  final String email;
  final String passwordHash;
  final String phone;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props =>
      [userId, name, email, passwordHash, phone, role, createdAt, updatedAt];
}

class Customer extends User {
  const Customer({
    required super.userId,
    required super.name,
    required super.email,
    required super.passwordHash,
    required super.phone,
    required super.createdAt,
    required super.updatedAt,
    this.savedAddresses = const [],
    this.defaultAddressId,
    this.loyaltyPoints = 0,
  }) : super(role: UserRole.customer);

  final List<Address> savedAddresses;
  final String? defaultAddressId;
  final int loyaltyPoints;

  @override
  List<Object?> get props =>
      [...super.props, savedAddresses, defaultAddressId, loyaltyPoints];
}

class ServiceProvider extends User {
  const ServiceProvider({
    required super.userId,
    required super.name,
    required super.email,
    required super.passwordHash,
    required super.phone,
    required super.createdAt,
    required super.updatedAt,
    this.bio = '',
    this.skills = const [],
    this.averageRating = 0,
    this.isVerified = false,
    this.isActive = true,
    this.latitude = 0,
    this.longitude = 0,
    this.distanceKm,
  }) : super(role: UserRole.provider);

  final String bio;
  final List<ServiceCategory> skills;
  final double averageRating;
  final bool isVerified;
  final bool isActive;
  final double latitude;
  final double longitude;
  final double? distanceKm;

  @override
  List<Object?> get props => [
        ...super.props,
        bio,
        skills,
        averageRating,
        isVerified,
        isActive,
        latitude,
        longitude,
        distanceKm,
      ];
}
