import 'package:equatable/equatable.dart';

class ProviderReview extends Equatable {
  const ProviderReview({
    required this.reviewId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String reviewId;
  final String reviewerName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  @override
  List<Object?> get props => [reviewId, reviewerName, rating, comment, createdAt];
}
