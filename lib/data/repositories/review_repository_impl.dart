import 'package:localservicemarket/core/error/exceptions.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/data/datasources/remote/api_data_source.dart';
import 'package:localservicemarket/data/models/review_model.dart';
import 'package:localservicemarket/domain/entities/review.dart';
import 'package:localservicemarket/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._api);

  final ApiDataSource _api;

  @override
  Future<Review> submitReview({
    required String bookingId,
    required String reviewerId,
    required String providerId,
    required int rating,
    String comment = '',
  }) async {
    try {
      final json = await _api.submitReview(
        bookingId: bookingId,
        reviewerId: reviewerId,
        providerId: providerId,
        rating: rating,
        comment: comment,
      );
      return ReviewModel.fromJson(json);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<bool> hasReviewForBooking(String bookingId) async {
    await _api.ensureInitialized();
    return _api.hasReview(bookingId);
  }

  @override
  Future<List<Review>> getProviderReviews(String providerId) async {
    await _api.ensureInitialized();
    // Reviews are embedded in mock store; filter client-side when needed.
    return [];
  }
}
