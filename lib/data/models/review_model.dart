import 'package:localservicemarket/domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.reviewId,
    required super.bookingId,
    required super.reviewerId,
    required super.providerId,
    required super.rating,
    super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['reviewId'] as String,
      bookingId: json['bookingId'] as String,
      reviewerId: json['reviewerId'] as String,
      providerId: json['providerId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'reviewId': reviewId,
        'bookingId': bookingId,
        'reviewerId': reviewerId,
        'providerId': providerId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };
}
