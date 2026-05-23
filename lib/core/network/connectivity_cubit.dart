import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityState extends Equatable {
  const ConnectivityState({
    this.isOnline = true,
    this.showOfflinePage = false,
  });

  final bool isOnline;
  final bool showOfflinePage;

  ConnectivityState copyWith({bool? isOnline, bool? showOfflinePage}) {
    return ConnectivityState(
      isOnline: isOnline ?? this.isOnline,
      showOfflinePage: showOfflinePage ?? this.showOfflinePage,
    );
  }

  @override
  List<Object?> get props => [isOnline, showOfflinePage];
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit() : super(const ConnectivityState()) {
    _subscription = Connectivity().onConnectivityChanged.listen(_onChanged);
    _check();
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> _check() async {
    final result = await Connectivity().checkConnectivity();
    _onChanged(result);
  }

  void _onChanged(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    emit(
      ConnectivityState(
        isOnline: online,
        showOfflinePage: !online,
      ),
    );
  }

  /// Call when an API request fails due to network.
  void reportNetworkFailure() {
    emit(state.copyWith(showOfflinePage: true, isOnline: false));
  }

  void clearOfflinePage() {
    emit(state.copyWith(showOfflinePage: false));
  }

  Future<void> retry() async {
    await _check();
    if (state.isOnline) {
      emit(const ConnectivityState(isOnline: true, showOfflinePage: false));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

/// True for API mapping to [NetworkException] (timeouts, unreachable host, etc.).
bool isNetworkDioError(DioException e) {
  return e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      (e.type == DioExceptionType.unknown &&
          (e.message?.toLowerCase().contains('socket') == true ||
              e.message?.toLowerCase().contains('network') == true));
}

/// Only true when the phone likely has no internet — not slow servers.
bool isDeviceOfflineError(DioException e) {
  if (e.type == DioExceptionType.connectionError) return true;
  if (e.type == DioExceptionType.unknown) {
    final msg = e.message?.toLowerCase() ?? '';
    return msg.contains('failed host lookup') ||
        msg.contains('network is unreachable') ||
        msg.contains('no address associated');
  }
  return false;
}
