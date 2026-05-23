import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/data/datasources/remote/api_data_source.dart';
import 'package:localservicemarket/data/models/service_category_model.dart';
import 'package:localservicemarket/data/models/service_model.dart';
import 'package:localservicemarket/data/models/user_model.dart';
import 'package:localservicemarket/domain/entities/provider_profile.dart';
import 'package:localservicemarket/domain/entities/provider_review.dart';
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
    double radiusKm = 10000,
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

  @override
  Future<ProviderProfile> getProviderProfile(String providerId) async {
    try {
      await _api.ensureInitialized();
      final json = await _api.getProviderProfile(providerId);
      final provider = UserModel.fromJson(json);
      if (provider is! ServiceProvider) {
        throw const ServerFailure('Provider not found');
      }
      final services = (json['services'] as List<dynamic>? ?? [])
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ProviderProfile(
        provider: provider,
        services: services,
        reviewCount: json['reviewCount'] as int? ?? 0,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<ProviderReview>> getProviderReviews(String providerId) async {
    try {
      await _api.ensureInitialized();
      final list = await _api.getProviderReviews(providerId);
      return list
          .map(
            (r) => ProviderReview(
              reviewId: r['reviewId'] as String,
              reviewerName: r['reviewerName'] as String? ?? 'Customer',
              rating: r['rating'] as int,
              comment: r['comment'] as String? ?? '',
              createdAt: DateTime.parse(r['createdAt'] as String),
            ),
          )
          .toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
