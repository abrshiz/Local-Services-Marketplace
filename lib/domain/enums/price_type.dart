enum PriceType {
  fixed,
  hourly;

  static PriceType fromString(String value) {
    return PriceType.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PriceType.fixed,
    );
  }

  String get wireValue => name.toUpperCase();
}
