import 'package:flutter_test/flutter_test.dart';
import 'package:localservicemarket/domain/enums/user_role.dart';

void main() {
  test('UserRole wire values match API contract', () {
    expect(UserRole.customer.wireValue, 'CUSTOMER');
    expect(UserRole.provider.wireValue, 'PROVIDER');
    expect(UserRole.fromString('ADMIN'), UserRole.admin);
  });
}
