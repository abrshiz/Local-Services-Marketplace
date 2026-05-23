import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/domain/enums/price_type.dart';
import 'package:localservicemarket/domain/repositories/discovery_repository.dart';
import 'package:localservicemarket/domain/repositories/location_repository.dart';
import 'package:localservicemarket/presentation/customer/discovery/bloc/discovery_state.dart';

class DiscoveryCubit extends Cubit<DiscoveryState> {
  DiscoveryCubit(this._discovery, this._location) : super(const DiscoveryState());

  final DiscoveryRepository _discovery;
  final LocationRepository _location;

  Future<void> load({bool refreshLocation = true}) async {
    emit(state.copyWith(status: DiscoveryStatus.loading, errorMessage: null));
    try {
      var lat = state.latitude;
      var lng = state.longitude;
      if (refreshLocation) {
        try {
          final pos = await _location.getCurrentPosition();
          lat = pos.latitude;
          lng = pos.longitude;
        } catch (_) {
          // Fallback to default SF coords for emulators.
        }
      }

      final categories = await _discovery.getCategories();
      final services = await _discovery.getServices(
        categoryId: state.selectedCategoryId,
      );
      final providers = await _discovery.getNearbyProviders(
        latitude: lat,
        longitude: lng,
        categoryId: state.selectedCategoryId,
        minRating: state.minRating,
        priceType: state.priceTypeFilter,
        query: state.query.isEmpty ? null : state.query,
      );

      emit(
        state.copyWith(
          status: DiscoveryStatus.loaded,
          categories: categories,
          services: services,
          providers: providers,
          latitude: lat,
          longitude: lng,
        ),
      );
    } on Failure catch (e) {
      emit(state.copyWith(
        status: DiscoveryStatus.failure,
        errorMessage: e.message,
      ));
    }
  }

  void setCategory(String? categoryId) {
    emit(state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
    ));
    load(refreshLocation: false);
  }

  void setFilters({double? minRating, PriceType? priceType}) {
    emit(state.copyWith(minRating: minRating, priceTypeFilter: priceType));
    load(refreshLocation: false);
  }

  void setQuery(String query) {
    emit(state.copyWith(query: query));
    load(refreshLocation: false);
  }
}
