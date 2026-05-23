import 'dart:async';
import 'dart:math';

import 'package:localservicemarket/core/error/exceptions.dart';
import 'package:localservicemarket/data/datasources/local/local_cache.dart';
import 'package:localservicemarket/data/models/booking_model.dart';
import 'package:localservicemarket/data/models/payment_model.dart';
import 'package:localservicemarket/data/models/review_model.dart';
import 'package:localservicemarket/data/models/service_category_model.dart';
import 'package:localservicemarket/data/models/service_model.dart';
import 'package:localservicemarket/data/models/time_slot_model.dart';
import 'package:localservicemarket/domain/enums/booking_status.dart';
import 'package:localservicemarket/domain/enums/payment_method.dart';
import 'package:localservicemarket/domain/enums/payment_status.dart';
import 'package:localservicemarket/domain/enums/price_type.dart';
import 'package:localservicemarket/data/datasources/remote/api_data_source.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';
import 'package:uuid/uuid.dart';

/// In-memory + persisted mock backend simulating REST behavior.
class MockApiDataSource implements ApiDataSource {
  MockApiDataSource(this._cache);

  final LocalCache _cache;
  final _uuid = const Uuid();
  final _pendingController =
      StreamController<Map<String, List<Map<String, dynamic>>>>.broadcast();

  static const demoPassword = 'password123';

  Future<void> ensureInitialized() async {
    if (_cache.readStore() != null) return;
    await _seed();
  }

  Map<String, dynamic> _store() {
    final s = _cache.readStore();
    if (s == null) throw CacheException('Store not initialized');
    return s;
  }

  Future<void> _persist() async {
    await _cache.writeStore(_store());
    _notifyPending();
  }

  void _addProviderCatalog(
    String providerId,
    String providerName,
    List<String> categoryIds,
  ) {
    final cats = (_store()['categories'] as List).cast<Map<String, dynamic>>();
    final services = (_store()['services'] as List).cast<Map<String, dynamic>>();
    final slots = (_store()['slots'] as List).cast<Map<String, dynamic>>();
    final now = DateTime.now().toUtc();

    for (final catId in categoryIds) {
      Map<String, dynamic>? cat;
      for (final c in cats) {
        if (c['categoryId'] == catId) {
          cat = c;
          break;
        }
      }
      if (cat == null) continue;
      services.add(
        ServiceModel(
          serviceId: _uuid.v4(),
          providerId: providerId,
          categoryId: catId,
          title: '$providerName — ${cat['name']}',
          description:
              'Professional ${(cat['name'] as String).toLowerCase()} services',
          priceType: PriceType.fixed,
          basePrice: 85,
        ).toJson(),
      );
    }

    for (var d = 0; d < 14; d++) {
      final day = DateTime(now.year, now.month, now.day + d);
      for (final hour in [9, 11, 14, 16]) {
        final start = DateTime(day.year, day.month, day.day, hour);
        if (start.isBefore(now.subtract(const Duration(hours: 1)))) continue;
        slots.add(
          TimeSlotModel(
            slotId: _uuid.v4(),
            providerId: providerId,
            startTime: start,
            endTime: start.add(const Duration(hours: 2)),
            isAvailable: true,
          ).toJson(),
        );
      }
    }
  }

  void _notifyPending() {
    final bookings = (_store()['bookings'] as List).cast<Map<String, dynamic>>();
    final byProvider = <String, List<Map<String, dynamic>>>{};
    for (final b in bookings) {
      if (b['status'] == BookingStatus.pending.wireValue) {
        byProvider.putIfAbsent(b['providerId'] as String, () => []).add(b);
      }
    }
    _pendingController.add(byProvider);
  }

  Stream<List<Map<String, dynamic>>> watchProviderPending(String providerId) {
    return _pendingController.stream.map(
      (map) => map[providerId] ?? const [],
    );
  }

  Future<void> _seed() async {
    final now = DateTime.now().toUtc();
    const catCleaning = 'a1111111-1111-4111-8111-111111111101';
    const catPlumbing = 'a1111111-1111-4111-8111-111111111102';
    const catElectrical = 'a1111111-1111-4111-8111-111111111103';
    const catGarden = 'a1111111-1111-4111-8111-111111111104';

    final categories = [
      ServiceCategoryModel(
        categoryId: catCleaning,
        name: 'Cleaning',
        description: 'Home & office cleaning',
        iconUrl: 'cleaning_services',
      ),
      ServiceCategoryModel(
        categoryId: catPlumbing,
        name: 'Plumbing',
        description: 'Repairs and installations',
        iconUrl: 'plumbing',
      ),
      ServiceCategoryModel(
        categoryId: catElectrical,
        name: 'Electrical',
        description: 'Wiring and fixtures',
        iconUrl: 'electrical_services',
      ),
      ServiceCategoryModel(
        categoryId: catGarden,
        name: 'Gardening',
        description: 'Lawn care and landscaping',
        iconUrl: 'yard',
      ),
    ];

    const customerId = 'b2222222-2222-4222-8222-222222222201';
    const provider1 = 'c3333333-3333-4333-8333-333333333301';
    const provider2 = 'c3333333-3333-4333-8333-333333333302';
    const addrId = 'd4444444-4444-4444-8444-444444444401';

    final customer = {
      'userId': customerId,
      'name': 'Alex Customer',
      'email': 'customer@demo.com',
      'passwordHash': demoPassword,
      'phone': '+1-555-0100',
      'role': UserRole.customer.wireValue,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'savedAddresses': [
        {
          'addressId': addrId,
          'userId': customerId,
          'label': 'Home',
          'street': '123 Market St',
          'city': 'San Francisco',
          'state': 'CA',
          'country': 'USA',
          'postalCode': '94103',
          'latitude': 37.7749,
          'longitude': -122.4194,
          'isDefault': true,
        },
      ],
      'defaultAddressId': addrId,
      'loyaltyPoints': 120,
    };

    final providers = [
      {
        'userId': provider1,
        'name': 'Jordan Clean Co.',
        'email': 'provider1@demo.com',
        'passwordHash': demoPassword,
        'phone': '+1-555-0201',
        'role': UserRole.provider.wireValue,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'bio': 'Eco-friendly cleaning with 5+ years experience.',
        'skills': [categories[0].toJson()],
        'averageRating': 4.8,
        'isVerified': true,
        'isActive': true,
        'latitude': 37.7810,
        'longitude': -122.4110,
      },
      {
        'userId': provider2,
        'name': 'Spark Electric',
        'email': 'provider2@demo.com',
        'passwordHash': demoPassword,
        'phone': '+1-555-0202',
        'role': UserRole.provider.wireValue,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'bio': 'Licensed electrician for residential jobs.',
        'skills': [categories[2].toJson()],
        'averageRating': 4.5,
        'isVerified': true,
        'isActive': true,
        'latitude': 37.7690,
        'longitude': -122.4290,
      },
    ];

    final services = [
      ServiceModel(
        serviceId: 'e5555555-5555-4555-8555-555555555501',
        providerId: provider1,
        categoryId: catCleaning,
        title: 'Standard Home Clean',
        description: '2-hour deep clean for apartments up to 80m²',
        priceType: PriceType.fixed,
        basePrice: 89,
      ),
      ServiceModel(
        serviceId: 'e5555555-5555-4555-8555-555555555502',
        providerId: provider1,
        categoryId: catCleaning,
        title: 'Hourly Touch-up',
        description: 'Flexible hourly cleaning',
        priceType: PriceType.hourly,
        basePrice: 45,
      ),
      ServiceModel(
        serviceId: 'e5555555-5555-4555-8555-555555555503',
        providerId: provider2,
        categoryId: catElectrical,
        title: 'Outlet Installation',
        description: 'Install or replace wall outlets',
        priceType: PriceType.fixed,
        basePrice: 120,
      ),
    ];

    final slots = <Map<String, dynamic>>[];
    for (final pid in [provider1, provider2]) {
      for (var d = 0; d < 14; d++) {
        final day = DateTime(now.year, now.month, now.day + d);
        for (final hour in [9, 11, 14, 16]) {
          final start = DateTime(day.year, day.month, day.day, hour);
          if (start.isBefore(now.subtract(const Duration(hours: 1)))) continue;
          slots.add(
            TimeSlotModel(
              slotId: _uuid.v4(),
              providerId: pid,
              startTime: start,
              endTime: start.add(const Duration(hours: 2)),
              isAvailable: true,
            ).toJson(),
          );
        }
      }
    }

    await _cache.writeStore({
      'categories': categories.map((c) => c.toJson()).toList(),
      'users': [customer, ...providers],
      'services': services.map((s) => s.toJson()).toList(),
      'slots': slots,
      'bookings': <Map<String, dynamic>>[],
      'payments': <Map<String, dynamic>>[],
      'reviews': <Map<String, dynamic>>[],
      'notifications': <Map<String, dynamic>>[],
    });
    _notifyPending();
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    await ensureInitialized();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final users = (_store()['users'] as List).cast<Map<String, dynamic>>();
    final match = users.cast<Map<String, dynamic>?>().firstWhere(
          (u) =>
              u!['email'] == email.trim().toLowerCase() &&
              u['passwordHash'] == password,
          orElse: () => null,
        );
    if (match == null) throw AuthException('Invalid email or password');
    await _cache.setSessionUserId(match['userId'] as String);
    return match;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? bio,
    List<String> categoryIds = const [],
  }) async {
    await ensureInitialized();
    if (role == UserRole.provider && categoryIds.isEmpty) {
      throw AuthException('Select at least one work category');
    }
    final users = (_store()['users'] as List).cast<Map<String, dynamic>>();
    if (users.any((u) => u['email'] == email.trim().toLowerCase())) {
      throw AuthException('Email already registered');
    }
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    final user = <String, dynamic>{
      'userId': id,
      'name': name,
      'email': email.trim().toLowerCase(),
      'passwordHash': password,
      'phone': phone,
      'role': role.wireValue,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
    if (role == UserRole.provider) {
      final cats = (_store()['categories'] as List).cast<Map<String, dynamic>>();
      final skills = <Map<String, dynamic>>[];
      for (final catId in categoryIds) {
        final cat = cats.cast<Map<String, dynamic>?>().firstWhere(
              (c) => c!['categoryId'] == catId,
              orElse: () => null,
            );
        if (cat != null) skills.add(Map<String, dynamic>.from(cat));
      }
      user.addAll({
        'bio': bio ?? '',
        'skills': skills,
        'averageRating': 0,
        'isVerified': false,
        'isActive': true,
        'latitude': 37.7749,
        'longitude': -122.4194,
      });
      _addProviderCatalog(id, name, categoryIds);
    } else {
      user.addAll({
        'savedAddresses': [],
        'defaultAddressId': null,
        'loyaltyPoints': 0,
      });
    }
    users.add(user);
    await _persist();
    await _cache.setSessionUserId(id);
    return user;
  }

  Future<Map<String, dynamic>?> currentUser() async {
    await ensureInitialized();
    final id = _cache.getSessionUserId();
    if (id == null) return null;
    final users = (_store()['users'] as List).cast<Map<String, dynamic>>();
    return users.cast<Map<String, dynamic>?>().firstWhere(
          (u) => u!['userId'] == id,
          orElse: () => null,
        );
  }

  Future<void> logout() => _cache.setSessionUserId(null);

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return (_store()['categories'] as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> getServices({
    String? categoryId,
    String? providerId,
  }) async {
    var list = (_store()['services'] as List).cast<Map<String, dynamic>>();
    if (categoryId != null) {
      list = list.where((s) => s['categoryId'] == categoryId).toList();
    }
    if (providerId != null) {
      list = list.where((s) => s['providerId'] == providerId).toList();
    }
    return list.where((s) => s['isActive'] == true).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getNearbyProviders({
    required double latitude,
    required double longitude,
    double radiusKm = 10000,
    String? categoryId,
    double? minRating,
    PriceType? priceType,
    String? query,
  }) async {
    final users = (_store()['users'] as List).cast<Map<String, dynamic>>();
    final services = (_store()['services'] as List).cast<Map<String, dynamic>>();
    var providers = users
        .where((u) => u['role'] == UserRole.provider.wireValue && u['isActive'] == true)
        .toList();

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      providers = providers
          .where((p) => (p['name'] as String).toLowerCase().contains(q))
          .toList();
    }

    if (categoryId != null) {
      final providerIds = services
          .where((s) => s['categoryId'] == categoryId)
          .map((s) => s['providerId'] as String)
          .toSet();
      providers = providers.where((p) => providerIds.contains(p['userId'])).toList();
    }

    if (minRating != null) {
      providers = providers
          .where((p) => (p['averageRating'] as num) >= minRating)
          .toList();
    }

    if (priceType != null) {
      final providerIds = services
          .where((s) => s['priceType'] == priceType.wireValue)
          .map((s) => s['providerId'] as String)
          .toSet();
      providers = providers.where((p) => providerIds.contains(p['userId'])).toList();
    }

    providers.sort((a, b) {
      final da = _distanceKm(latitude, longitude,
          (a['latitude'] as num).toDouble(), (a['longitude'] as num).toDouble());
      final db = _distanceKm(latitude, longitude,
          (b['latitude'] as num).toDouble(), (b['longitude'] as num).toDouble());
      return da.compareTo(db);
    });

    return providers.where((p) {
      final d = _distanceKm(
        latitude,
        longitude,
        (p['latitude'] as num).toDouble(),
        (p['longitude'] as num).toDouble(),
      );
      return d <= radiusKm;
    }).toList();
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  @override
  Future<List<Map<String, dynamic>>> getSlotsForDay(
    String providerId,
    DateTime day,
  ) async {
    final slots = (_store()['slots'] as List).cast<Map<String, dynamic>>();
    return slots.where((s) {
      if (s['providerId'] != providerId || s['isAvailable'] != true) return false;
      final start = DateTime.parse(s['startTime'] as String);
      return start.year == day.year &&
          start.month == day.month &&
          start.day == day.day;
    }).toList()
      ..sort((a, b) => DateTime.parse(a['startTime'] as String)
          .compareTo(DateTime.parse(b['startTime'] as String)));
  }

  Future<Map<String, dynamic>> createBooking({
    required String customerId,
    required String providerId,
    required String serviceId,
    required String slotId,
    required String addressId,
    required double totalPrice,
    String notes = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final users = (_store()['users'] as List).cast<Map<String, dynamic>>();
    final provider = users.firstWhere(
      (u) => u['userId'] == providerId,
      orElse: () => throw ProviderUnavailableException('Provider not found'),
    );
    if (provider['isActive'] != true) {
      throw ProviderUnavailableException('Provider is currently unavailable');
    }

    final slots = (_store()['slots'] as List).cast<Map<String, dynamic>>();
    final slotIndex = slots.indexWhere((s) => s['slotId'] == slotId);
    if (slotIndex < 0) throw SlotUnavailableException('Time slot not found');
    final slot = slots[slotIndex];
    if (slot['isAvailable'] != true) {
      throw SlotUnavailableException('This time slot is no longer available');
    }

    slots[slotIndex] = {...slot, 'isAvailable': false};
    final start = DateTime.parse(slot['startTime'] as String);
    final end = DateTime.parse(slot['endTime'] as String);

    final booking = BookingModel(
      bookingId: _uuid.v4(),
      customerId: customerId,
      providerId: providerId,
      serviceId: serviceId,
      slotId: slotId,
      scheduledTime: start,
      endTime: end,
      status: BookingStatus.pending,
      totalPrice: totalPrice,
      addressId: addressId,
      notes: notes,
    ).toJson();

    (_store()['bookings'] as List).add(booking);
    (_store()['notifications'] as List).add({
      'id': _uuid.v4(),
      'userId': providerId,
      'title': 'New booking request',
      'body': 'A customer requested a service at ${start.toLocal()}',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    await _persist();
    return booking;
  }

  Future<Map<String, dynamic>> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    final bookings = (_store()['bookings'] as List).cast<Map<String, dynamic>>();
    final i = bookings.indexWhere((b) => b['bookingId'] == bookingId);
    if (i < 0) throw BookingException('Booking not found');
    final booking = Map<String, dynamic>.from(bookings[i]);

    if (status == BookingStatus.cancelled &&
        booking['status'] != BookingStatus.completed.wireValue) {
      _releaseSlot(booking['slotId'] as String?);
    }

    if (status == BookingStatus.cancelled &&
        booking['status'] == BookingStatus.pending.wireValue) {
      _releaseSlot(booking['slotId'] as String?);
    }

    booking['status'] = status.wireValue;
    bookings[i] = booking;
    await _persist();
    return booking;
  }

  void _releaseSlot(String? slotId) {
    if (slotId == null) return;
    final slots = (_store()['slots'] as List).cast<Map<String, dynamic>>();
    final i = slots.indexWhere((s) => s['slotId'] == slotId);
    if (i >= 0) slots[i] = {...slots[i], 'isAvailable': true};
  }

  @override
  Future<List<Map<String, dynamic>>> getBookings({
    required String userId,
    required bool asProvider,
    BookingStatus? status,
  }) async {
    var list = (_store()['bookings'] as List).cast<Map<String, dynamic>>();
    list = list.where((b) {
      final match = asProvider ? b['providerId'] == userId : b['customerId'] == userId;
      if (!match) return false;
      if (status != null) return b['status'] == status.wireValue;
      return true;
    }).toList();
    list.sort((a, b) => DateTime.parse(b['scheduledTime'] as String)
        .compareTo(DateTime.parse(a['scheduledTime'] as String)));
    return list;
  }

  Future<Map<String, dynamic>> startService(String bookingId) async {
    final bookings = (_store()['bookings'] as List).cast<Map<String, dynamic>>();
    final i = bookings.indexWhere((b) => b['bookingId'] == bookingId);
    if (i < 0) throw BookingException('Booking not found');
    final b = Map<String, dynamic>.from(bookings[i]);
    b['serviceStartedAt'] = DateTime.now().toUtc().toIso8601String();
    bookings[i] = b;
    await _persist();
    return b;
  }

  Future<Map<String, dynamic>> completeService(String bookingId) async {
    final bookings = (_store()['bookings'] as List).cast<Map<String, dynamic>>();
    final i = bookings.indexWhere((b) => b['bookingId'] == bookingId);
    if (i < 0) throw BookingException('Booking not found');
    final b = Map<String, dynamic>.from(bookings[i]);
    b['status'] = BookingStatus.completed.wireValue;
    b['serviceCompletedAt'] = DateTime.now().toUtc().toIso8601String();
    bookings[i] = b;
    await _persist();
    return b;
  }

  Future<Map<String, dynamic>> initiatePayment({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
  }) async {
    final payment = PaymentModel(
      paymentId: _uuid.v4(),
      bookingId: bookingId,
      amount: amount,
      status: PaymentStatus.pending,
      method: method,
    ).toJson();
    (_store()['payments'] as List).add(payment);
    await _persist();
    return payment;
  }

  Future<Map<String, dynamic>> processPayment({
    required String paymentId,
    required bool simulateSuccess,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final payments = (_store()['payments'] as List).cast<Map<String, dynamic>>();
    final i = payments.indexWhere((p) => p['paymentId'] == paymentId);
    if (i < 0) throw PaymentException('Payment not found');

    if (!simulateSuccess) {
      payments[i] = {
        ...payments[i],
        'status': PaymentStatus.failed.wireValue,
      };
      await _persist();
      throw PaymentException('Payment declined by gateway');
    }

    payments[i] = {
      ...payments[i],
      'status': PaymentStatus.paid.wireValue,
      'transactionRef': 'TX-${paymentId.substring(0, 8).toUpperCase()}',
      'paidAt': DateTime.now().toUtc().toIso8601String(),
    };

    final bookingId = payments[i]['bookingId'] as String;
    await updateBookingStatus(bookingId, BookingStatus.confirmed);
    await _persist();
    return payments[i];
  }

  @override
  Future<Map<String, dynamic>?> paymentForBooking(String bookingId) async {
    final payments = (_store()['payments'] as List).cast<Map<String, dynamic>>();
    return payments.cast<Map<String, dynamic>?>().firstWhere(
          (p) => p!['bookingId'] == bookingId,
          orElse: () => null,
        );
  }

  Future<Map<String, dynamic>> submitReview({
    required String bookingId,
    required String reviewerId,
    required String providerId,
    required int rating,
    String comment = '',
  }) async {
    final reviews = (_store()['reviews'] as List).cast<Map<String, dynamic>>();
    if (reviews.any((r) => r['bookingId'] == bookingId)) {
      throw ServerException('Review already submitted for this booking');
    }
    final review = ReviewModel(
      reviewId: _uuid.v4(),
      bookingId: bookingId,
      reviewerId: reviewerId,
      providerId: providerId,
      rating: rating.clamp(1, 5),
      comment: comment,
      createdAt: DateTime.now().toUtc(),
    ).toJson();
    reviews.add(review);

    final users = (_store()['users'] as List).cast<Map<String, dynamic>>();
    final pi = users.indexWhere((u) => u['userId'] == providerId);
    if (pi >= 0) {
      final providerReviews = reviews.where((r) => r['providerId'] == providerId);
      final avg = providerReviews
              .map((r) => r['rating'] as int)
              .fold<int>(0, (a, b) => a + b) /
          providerReviews.length;
      users[pi] = {...users[pi], 'averageRating': avg};
    }
    await _persist();
    return review;
  }

  @override
  Future<bool> hasReview(String bookingId) async {
    return (_store()['reviews'] as List).cast<Map<String, dynamic>>().any(
          (r) => r['bookingId'] == bookingId,
        );
  }

  Map<String, dynamic>? userById(String id) {
    final users = (_store()['users'] as List).cast<Map<String, dynamic>>();
    return users.cast<Map<String, dynamic>?>().firstWhere(
          (u) => u!['userId'] == id,
          orElse: () => null,
        );
  }
}
