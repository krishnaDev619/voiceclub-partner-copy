import 'package:voiceclub_partner/core/constants/url_constants.dart';

class AvatarService {
  static final List<String> avatarUrls = [
    URLConstants.avatarUrl1,
    URLConstants.avatarUrl2,
    URLConstants.avatarUrl3,
    URLConstants.avatarUrl4,
  ];

  static String getRandomAvatarUrl() {
    return avatarUrls[0];
  }

  static String getAvatarInitials(String? name) {
    try {
      final fullName = name ?? '';
      if (fullName.isEmpty) {
        return 'X';
      } else {
        List<String> nameParts = fullName.trim().split(' ');

        if (nameParts.length == 1) {
          return nameParts[0].substring(0, 1).toUpperCase();
        } else {
          String initials = '';
          for (String part in nameParts.getRange(0, 2)) {
            initials += part.substring(0, 1).toUpperCase();
          }
          return initials;
        }
      }
    } catch (_) {
      return 'X';
    }
  }

  static String getDemandAvatarUrl() {
    return avatarUrls[3];
  }
}
