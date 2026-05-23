import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.reviewId,
    required this.bookingId,
    required this.reviewerId,
    required this.providerId,
    required this.rating,
    this.comment = '',
    required this.createdAt,
  });

  final String reviewId;
  final String bookingId;
  final String reviewerId;
  final String providerId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [reviewId, bookingId, reviewerId, providerId, rating, comment, createdAt];
}
