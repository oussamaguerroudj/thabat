import 'package:flutter_test/flutter_test.dart';
import 'package:thabat/core/errors/failure.dart';

void main() {
  group('Failure equality', () {
    test('two ApiFailures with the same fields are equal', () {
      const a = ApiFailure(code: 'invalid_credentials', message: 'x', statusCode: 401);
      const b = ApiFailure(code: 'invalid_credentials', message: 'x', statusCode: 401);
      expect(a, equals(b));
    });

    test('ApiFailures with different codes are not equal', () {
      const a = ApiFailure(code: 'invalid_credentials', message: 'x', statusCode: 401);
      const b = ApiFailure(code: 'unverified', message: 'x', statusCode: 401);
      expect(a, isNot(equals(b)));
    });

    test('NetworkFailure carries a default Arabic message', () {
      const failure = NetworkFailure();
      expect(failure.message, isNotEmpty);
    });

    test('SessionExpiredFailure and ApiFailure are distinct types', () {
      const session = SessionExpiredFailure();
      const api = ApiFailure(code: 'unauthorized', message: 'x');
      expect(session, isNot(isA<ApiFailure>()));
      expect(api, isNot(isA<SessionExpiredFailure>()));
    });
  });
}
