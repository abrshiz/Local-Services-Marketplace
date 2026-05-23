enum UserRole {
  customer,
  provider,
  admin;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => UserRole.customer,
    );
  }

  String get wireValue => name.toUpperCase();
}
