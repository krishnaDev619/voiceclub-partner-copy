class BlockedAccountIdParser {
  const BlockedAccountIdParser._();

  /// Extracts the account ID that the register API appends to a 406 message.
  ///
  /// Any trailing punctuation is ignored so messages ending in `#12345` or
  /// `account ID: 12345.` are both supported.
  static String? fromMessage(String? message) {
    if (message == null || message.trim().isEmpty) return null;

    final match = RegExp(r'(\d+)\D*$').firstMatch(message.trim());
    return match?.group(1);
  }
}
