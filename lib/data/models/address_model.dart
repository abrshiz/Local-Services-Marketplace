import 'package:localservicemarket/domain/entities/address.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.addressId,
    required super.userId,
    required super.label,
    required super.street,
    required super.city,
    required super.state,
    required super.country,
    required super.postalCode,
    required super.latitude,
    required super.longitude,
    super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressId: json['addressId'] as String,
      userId: json['userId'] as String,
      label: json['label'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      postalCode: json['postalCode'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'addressId': addressId,
        'userId': userId,
        'label': label,
        'street': street,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
      };
}
