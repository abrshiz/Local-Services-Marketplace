enum PaymentMethod {
  card,
  cash,
  wallet,
  other;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => PaymentMethod.card,
    );
  }

  String get wireValue => name.toUpperCase();
}
