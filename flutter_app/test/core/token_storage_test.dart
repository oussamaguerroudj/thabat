import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thabat/core/storage/token_storage.dart';

void main() {
  setUp(() {
    // flutter_secure_storage's documented in-memory mock for tests — avoids
    // touching the real platform Keychain/Keystore channel.
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('TokenStorage', () {
    test('hasSession is false before any tokens are saved', () async {
      final storage = TokenStorage();
      expect(await storage.hasSession(), isFalse);
    });

    test('saveTokenPair makes both tokens readable and hasSession true',
        () async {
      final storage = TokenStorage();
      await storage.saveTokenPair(accessToken: 'access-1', refreshToken: 'refresh-1');

      expect(await storage.readAccessToken(), 'access-1');
      expect(await storage.readRefreshToken(), 'refresh-1');
      expect(await storage.hasSession(), isTrue);
    });

    test('updateAccessToken leaves the refresh token untouched', () async {
      final storage = TokenStorage();
      await storage.saveTokenPair(accessToken: 'access-1', refreshToken: 'refresh-1');
      await storage.updateAccessToken('access-2');

      expect(await storage.readAccessToken(), 'access-2');
      expect(await storage.readRefreshToken(), 'refresh-1');
    });

    test('clear removes both tokens', () async {
      final storage = TokenStorage();
      await storage.saveTokenPair(accessToken: 'access-1', refreshToken: 'refresh-1');
      await storage.clear();

      expect(await storage.readAccessToken(), isNull);
      expect(await storage.readRefreshToken(), isNull);
      expect(await storage.hasSession(), isFalse);
    });
  });
}
