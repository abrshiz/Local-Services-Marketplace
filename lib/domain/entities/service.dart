import 'package:equatable/equatable.dart';
import 'package:localservicemarket/domain/enums/price_type.dart';

class Service extends Equatable {
  const Service({
    required this.serviceId,
    required this.providerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.priceType,
    required this.basePrice,
    this.isActive = true,
  });

  final String serviceId;
  final String providerId;
  final String categoryId;
  final String title;
  final String description;
  final PriceType priceType;
  final double basePrice;
  final bool isActive;

  @override
  List<Object?> get props => [
        serviceId,
        providerId,
        categoryId,
        title,
        description,
        priceType,
        basePrice,
        isActive,
      ];
}
