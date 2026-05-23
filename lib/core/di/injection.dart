import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:localservicemarket/core/config/app_config.dart';
import 'package:localservicemarket/core/network/connectivity_cubit.dart';
import 'package:localservicemarket/core/theme/theme_cubit.dart';
import 'package:localservicemarket/data/datasources/local/local_cache.dart';
import 'package:localservicemarket/data/datasources/remote/api_client.dart';
import 'package:localservicemarket/data/datasources/remote/api_data_source.dart';
import 'package:localservicemarket/data/datasources/remote/mock_api_datasource.dart';
import 'package:localservicemarket/data/datasources/remote/remote_api_data_source.dart';
import 'package:localservicemarket/data/repositories/auth_repository_impl.dart';
import 'package:localservicemarket/data/repositories/chat_repository_impl.dart';
import 'package:localservicemarket/data/repositories/booking_repository_impl.dart';
import 'package:localservicemarket/data/repositories/discovery_repository_impl.dart';
import 'package:localservicemarket/data/repositories/location_repository_impl.dart';
import 'package:localservicemarket/data/repositories/payment_repository_impl.dart';
import 'package:localservicemarket/data/repositories/review_repository_impl.dart';
import 'package:localservicemarket/domain/repositories/auth_repository.dart';
import 'package:localservicemarket/domain/repositories/chat_repository.dart';
import 'package:localservicemarket/domain/repositories/booking_repository.dart';
import 'package:localservicemarket/domain/repositories/discovery_repository.dart';
import 'package:localservicemarket/domain/repositories/location_repository.dart';
import 'package:localservicemarket/domain/repositories/payment_repository.dart';
import 'package:localservicemarket/domain/repositories/review_repository.dart';
import 'package:localservicemarket/presentation/auth/bloc/auth_cubit.dart';
import 'package:localservicemarket/presentation/customer/booking/bloc/booking_cubit.dart';
import 'package:localservicemarket/presentation/customer/discovery/bloc/discovery_cubit.dart';
import 'package:localservicemarket/presentation/customer/payment/bloc/payment_cubit.dart';
import 'package:localservicemarket/presentation/customer/review/bloc/review_cubit.dart';
import 'package:localservicemarket/presentation/customer/tracking/bloc/tracking_cubit.dart';
import 'package:localservicemarket/presentation/provider/dashboard/bloc/provider_dashboard_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => LocalCache(prefs));
  sl.registerLazySingleton(ConnectivityCubit.new);
  sl.registerLazySingleton(() => ThemeCubit(prefs));

  if (!AppConfig.useMockApi) {
    sl.registerLazySingleton(() => createApiClient(sl()));
  }

  sl.registerLazySingleton<ApiDataSource>(() {
    if (AppConfig.useMockApi) {
      return MockApiDataSource(sl());
    }
    return RemoteApiDataSource(sl<Dio>(), sl());
  });

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<DiscoveryRepository>(
    () => DiscoveryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ReviewRepository>(() => ReviewRepositoryImpl(sl()));
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(),
  );

  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerFactory(() => DiscoveryCubit(sl(), sl()));
  sl.registerFactory(() => BookingCubit(sl()));
  sl.registerFactory(() => PaymentCubit(sl()));
  sl.registerFactory(() => TrackingCubit(sl()));
  sl.registerFactory(() => ReviewCubit(sl()));
  sl.registerFactory(() => ProviderDashboardCubit(sl(), sl()));

  // Warm API in background — do not block first frame.
  sl<ApiDataSource>().ensureInitialized().catchError((_) {});
}
