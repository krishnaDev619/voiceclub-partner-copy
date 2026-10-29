import 'package:flutter_test/flutter_test.dart';
import 'package:voiceclub_partner/core/utils/blocked_account_id_parser.dart';

void main() {
  group('BlockedAccountIdParser', () {
    test('extracts an account ID at the end of a message', () {
      expect(
        BlockedAccountIdParser.fromMessage(
          'Account blocked due to poor performance. Account ID: 534512',
        ),
        '534512',
      );
    });

    test('allows trailing punctuation', () {
      expect(
        BlockedAccountIdParser.fromMessage('Blocked account #12345.'),
        '12345',
      );
    });

    test('returns null when no trailing account ID exists', () {
      expect(BlockedAccountIdParser.fromMessage('Account is blocked'), isNull);
    });
  });
}
