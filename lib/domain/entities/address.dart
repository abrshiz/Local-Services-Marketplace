import 'package:equatable/equatable.dart';

class Address extends Equatable {
  const Address({
    required this.addressId,
    required this.userId,
    required this.label,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  final String addressId;
  final String userId;
  final String label;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  String get fullLine => '$street, $city, $state $postalCode';

  Address copyWith({
    String? addressId,
    String? userId,
    String? label,
    String? street,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return Address(
      addressId: addressId ?? this.addressId,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
        addressId,
        userId,
        label,
        street,
        city,
        state,
        country,
        postalCode,
        latitude,
        longitude,
        isDefault,
      ];
}
