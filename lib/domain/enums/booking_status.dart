enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => BookingStatus.pending,
    );
  }

  String get wireValue => name.toUpperCase();
}
