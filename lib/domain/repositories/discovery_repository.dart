import 'package:localservicemarket/domain/entities/service.dart';
import 'package:localservicemarket/domain/entities/service_category.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/price_type.dart';

abstract class DiscoveryRepository {
  Future<List<ServiceCategory>> getCategories();
  Future<List<Service>> getServices({String? categoryId, String? providerId});
  Future<List<ServiceProvider>> getNearbyProviders({
    required double latitude,
    required double longitude,
    double radiusKm,
    String? categoryId,
    double? minRating,
    PriceType? priceType,
    String? query,
  });
}
