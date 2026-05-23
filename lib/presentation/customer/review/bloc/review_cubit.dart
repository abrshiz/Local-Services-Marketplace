import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localservicemarket/core/error/failures.dart';
import 'package:localservicemarket/domain/repositories/review_repository.dart';

enum ReviewFlowStatus { initial, submitting, success, failure, alreadySubmitted }

class ReviewState extends Equatable {
  const ReviewState({
    this.status = ReviewFlowStatus.initial,
    this.rating = 5,
    this.comment = '',
    this.errorMessage,
  });

  final ReviewFlowStatus status;
  final int rating;
  final String comment;
  final String? errorMessage;

  ReviewState copyWith({
    ReviewFlowStatus? status,
    int? rating,
    String? comment,
    String? errorMessage,
  }) {
    return ReviewState(
      status: status ?? this.status,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, rating, comment, errorMessage];
}

class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit(this._reviews) : super(const ReviewState());

  final ReviewRepository _reviews;

  Future<void> checkExisting(String bookingId) async {
    final exists = await _reviews.hasReviewForBooking(bookingId);
    if (exists) {
      emit(state.copyWith(status: ReviewFlowStatus.alreadySubmitted));
    }
  }

  void setRating(int rating) => emit(state.copyWith(rating: rating));

  void setComment(String comment) => emit(state.copyWith(comment: comment));

  Future<void> submit({
    required String bookingId,
    required String reviewerId,
    required String providerId,
  }) async {
    emit(state.copyWith(status: ReviewFlowStatus.submitting, errorMessage: null));
    try {
      await _reviews.submitReview(
        bookingId: bookingId,
        reviewerId: reviewerId,
        providerId: providerId,
        rating: state.rating,
        comment: state.comment,
      );
      emit(state.copyWith(status: ReviewFlowStatus.success));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: ReviewFlowStatus.failure,
        errorMessage: e.message,
      ));
    }
  }
}
