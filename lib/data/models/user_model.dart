import 'package:localservicemarket/data/models/address_model.dart';
import 'package:localservicemarket/data/models/service_category_model.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';

class UserModel {
  static User fromJson(Map<String, dynamic> json) {
    final role = UserRole.fromString(json['role'] as String);
    final createdAt = DateTime.parse(json['createdAt'] as String);
    final updatedAt = DateTime.parse(json['updatedAt'] as String);

    if (role == UserRole.provider) {
      return ServiceProvider(
        userId: json['userId'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        passwordHash: json['passwordHash'] as String,
        phone: json['phone'] as String,
        createdAt: createdAt,
        updatedAt: updatedAt,
        bio: json['bio'] as String? ?? '',
        skills: (json['skills'] as List<dynamic>? ?? [])
            .map((e) => ServiceCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
        isVerified: json['isVerified'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      );
    }

    return Customer(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      phone: json['phone'] as String,
      createdAt: createdAt,
      updatedAt: updatedAt,
      savedAddresses: (json['savedAddresses'] as List<dynamic>? ?? [])
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultAddressId: json['defaultAddressId'] as String?,
      loyaltyPoints: json['loyaltyPoints'] as int? ?? 0,
    );
  }

  static Map<String, dynamic> toJson(User user) {
    final base = {
      'userId': user.userId,
      'name': user.name,
      'email': user.email,
      'passwordHash': user.passwordHash,
      'phone': user.phone,
      'role': user.role.wireValue,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
    };

    if (user is ServiceProvider) {
      return {
        ...base,
        'bio': user.bio,
        'skills': user.skills
            .map((s) => ServiceCategoryModel(
                  categoryId: s.categoryId,
                  name: s.name,
                  description: s.description,
                  iconUrl: s.iconUrl,
                ).toJson())
            .toList(),
        'averageRating': user.averageRating,
        'isVerified': user.isVerified,
        'isActive': user.isActive,
        'latitude': user.latitude,
        'longitude': user.longitude,
        if (user.distanceKm != null) 'distanceKm': user.distanceKm,
      };
    }

    if (user is Customer) {
      return {
        ...base,
        'savedAddresses': user.savedAddresses
            .map((a) => AddressModel(
                  addressId: a.addressId,
                  userId: a.userId,
                  label: a.label,
                  street: a.street,
                  city: a.city,
                  state: a.state,
                  country: a.country,
                  postalCode: a.postalCode,
                  latitude: a.latitude,
                  longitude: a.longitude,
                  isDefault: a.isDefault,
                ).toJson())
            .toList(),
        'defaultAddressId': user.defaultAddressId,
        'loyaltyPoints': user.loyaltyPoints,
      };
    }

    return base;
  }
}
