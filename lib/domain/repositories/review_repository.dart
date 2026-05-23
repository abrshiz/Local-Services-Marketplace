import 'package:localservicemarket/domain/entities/review.dart';

abstract class ReviewRepository {
  Future<Review> submitReview({
    required String bookingId,
    required String reviewerId,
    required String providerId,
    required int rating,
    String comment,
  });
  Future<bool> hasReviewForBooking(String bookingId);
  Future<List<Review>> getProviderReviews(String providerId);
}
