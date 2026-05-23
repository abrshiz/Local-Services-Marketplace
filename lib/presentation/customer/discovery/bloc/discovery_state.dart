import 'package:equatable/equatable.dart';
import 'package:localservicemarket/domain/entities/service.dart';
import 'package:localservicemarket/domain/entities/service_category.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/domain/enums/price_type.dart';

enum DiscoveryStatus { initial, loading, loaded, failure }

class DiscoveryState extends Equatable {
  const DiscoveryState({
    this.status = DiscoveryStatus.initial,
    this.categories = const [],
    this.services = const [],
    this.providers = const [],
    this.latitude = 37.7749,
    this.longitude = -122.4194,
    this.selectedCategoryId,
    this.minRating,
    this.priceTypeFilter,
    this.query = '',
    this.errorMessage,
  });

  final DiscoveryStatus status;
  final List<ServiceCategory> categories;
  final List<Service> services;
  final List<ServiceProvider> providers;
  final double latitude;
  final double longitude;
  final String? selectedCategoryId;
  final double? minRating;
  final PriceType? priceTypeFilter;
  final String query;
  final String? errorMessage;

  DiscoveryState copyWith({
    DiscoveryStatus? status,
    List<ServiceCategory>? categories,
    List<Service>? services,
    List<ServiceProvider>? providers,
    double? latitude,
    double? longitude,
    String? selectedCategoryId,
    double? minRating,
    PriceType? priceTypeFilter,
    String? query,
    String? errorMessage,
    bool clearCategory = false,
  }) {
    return DiscoveryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      services: services ?? this.services,
      providers: providers ?? this.providers,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      selectedCategoryId:
          clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      minRating: minRating ?? this.minRating,
      priceTypeFilter: priceTypeFilter ?? this.priceTypeFilter,
      query: query ?? this.query,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        services,
        providers,
        latitude,
        longitude,
        selectedCategoryId,
        minRating,
        priceTypeFilter,
        query,
        errorMessage,
      ];
}
