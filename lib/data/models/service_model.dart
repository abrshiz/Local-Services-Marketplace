import 'package:localservicemarket/domain/entities/service.dart';
import 'package:localservicemarket/domain/enums/price_type.dart';

class ServiceModel extends Service {
  const ServiceModel({
    required super.serviceId,
    required super.providerId,
    required super.categoryId,
    required super.title,
    required super.description,
    required super.priceType,
    required super.basePrice,
    super.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['serviceId'] as String,
      providerId: json['providerId'] as String,
      categoryId: json['categoryId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priceType: PriceType.fromString(json['priceType'] as String),
      basePrice: (json['basePrice'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'providerId': providerId,
        'categoryId': categoryId,
        'title': title,
        'description': description,
        'priceType': priceType.wireValue,
        'basePrice': basePrice,
        'isActive': isActive,
      };
}
