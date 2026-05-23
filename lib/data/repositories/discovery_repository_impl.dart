import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/data/datasources/remote/api_data_source.dart';
import 'package:localservicemarket/data/models/service_category_model.dart';
import 'package:localservicemarket/data/models/service_model.dart';
import 'package:localservicemarket/data/models/user_model.dart';
import 'package:localservicemarket/domain/entities/service.dart';
import 'package:localservicemarket/domain/entities/service_category.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/price_type.dart';
import 'package:localservicemarket/domain/repositories/discovery_repository.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  DiscoveryRepositoryImpl(this._api);

  final ApiDataSource _api;

  @override
  Future<List<ServiceCategory>> getCategories() async {
    try {
      await _api.ensureInitialized();
      final list = await _api.getCategories();
      return list.map(ServiceCategoryModel.fromJson).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<Service>> getServices({String? categoryId, String? providerId}) async {
    try {
      await _api.ensureInitialized();
      final list = await _api.getServices(
        categoryId: categoryId,
        providerId: providerId,
      );
      return list.map(ServiceModel.fromJson).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<ServiceProvider>> getNearbyProviders({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    String? categoryId,
    double? minRating,
    PriceType? priceType,
    String? query,
  }) async {
    try {
      await _api.ensureInitialized();
      final list = await _api.getNearbyProviders(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        categoryId: categoryId,
        minRating: minRating,
        priceType: priceType,
        query: query,
      );
      return list.map(UserModel.fromJson).whereType<ServiceProvider>().toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
