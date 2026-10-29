import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/domain/usecases/social/create_post.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CreateTextPostController extends GetxController {
  final Rx<Color> selectedColor = const Color(0xFF7A4069).obs;
  final RxString text = ''.obs;
  final RxDouble fontSize = 24.0.obs;
  final RxString selectedFont = 'Roboto'.obs;
  final RxBool isUploading = false.obs;

  final List<Color> availableColors = [
    const Color(0xFF7A4069),
    const Color(0xFF205072),
    const Color(0xFF145C52),
    const Color(0xFF2E1F27),
    const Color(0xFF00C4C8),
    const Color(0xFF3D2C8D),
  ];

  final List<Map<String, dynamic>> availableFonts = [
    {'name': 'Roboto', 'style': GoogleFonts.roboto},
    {'name': 'Playfair Display', 'style': GoogleFonts.playfairDisplay},
    {'name': 'Montserrat', 'style': GoogleFonts.montserrat},
    {'name': 'Dancing Script', 'style': GoogleFonts.dancingScript},
    {'name': 'Poppins', 'style': GoogleFonts.poppins},
    {'name': 'Lato', 'style': GoogleFonts.lato},
    {'name': 'Raleway', 'style': GoogleFonts.raleway},
  ];

  TextStyle getCurrentFontStyle({double? size}) {
    final fontStyle =
        availableFonts.firstWhere(
              (font) => font['name'] == selectedFont.value,
            )['style']
            as Function;
    final fontSize = size ?? this.fontSize.value;
    return fontStyle(
      fontSize: fontSize.toDouble(),
      color: Colors.white,
      fontWeight: FontWeight.w500,
    );
  }

  void updateText(String newText) {
    text.value = newText;
    _adjustFontSize();
  }

  void updateColor(Color color) {
    selectedColor.value = color;
  }

  void updateFont(String font) {
    selectedFont.value = font;
    _adjustFontSize();
  }

  void _adjustFontSize() {
    // Start with maximum font size
    double newSize = 24.0;

    // If text is empty, reset to default size
    if (text.value.isEmpty) {
      fontSize.value = newSize;
      return;
    }

    // Calculate text size with current font size
    final textPainter = TextPainter(
      text: TextSpan(
        text: text.value,
        style: getCurrentFontStyle(size: newSize),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 10, // Maximum number of lines allowed
    )..layout(maxWidth: Get.width * 0.8); // 80% of screen width

    // If text doesn't fit, reduce font size
    while (textPainter.didExceedMaxLines ||
        textPainter.height > Get.height * 0.4) {
      newSize -= 1;
      if (newSize < 16) break; // Minimum font size

      textPainter.text = TextSpan(
        text: text.value,
        style: getCurrentFontStyle(size: newSize),
      );
      textPainter.layout(maxWidth: Get.width * 0.8);
    }

    fontSize.value = newSize;
  }

  Future<void> publishPost() async {
    if (text.value.trim().isEmpty) {
      AlertService.showSnackBar(
        title: LocaleKeys.livePleaseEnterSomeText.tr,
        subtitle: LocaleKeys.liveTextCannotBeEmpty.tr,
        snackBarType: SnackBarType.Error,
      );
      return;
    }
    try {
      isUploading.value = true;
      final response = await sl<CreatePostUsecase>().call(
        CreatePostParams(
          postType: PostMediaType.TEXT,
          textContent: text.value.trim(),
          mediaUrl: '',
          postColor: selectedColor.value.toHex(),
          fontStyle: selectedFont.value,
          textOverlay: text.value.trim(),
        ),
      );
      if (response.error != null) {
        AlertService.showSnackBar(
          title: response.errorMessage,
          subtitle: response.errorDetail,
          snackBarType: SnackBarType.Error,
        );
      } else {
        Get.find<ExploreController>().fetchForYouPosts(page: 1);
        Get.find<ExploreController>().showPostStatusWidget(
          response.data!.postId ?? '',
        );
        sl<AnalyticsService>().trackEvent(
          "newPostSuccessPartner",
          eventProperties: {
            "postType": PostMediaType.TEXT.name,
            "postText": text.value.trim(),
            "postId": response.data?.postId,
          },
        );
        Get.back(closeOverlays: true);
      }
      isUploading.value = false;
    } catch (e) {
      isUploading.value = false;
      AlertService.showSnackBar(
        title: LocaleKeys.somethingWentWrong.tr,
        subtitle: LocaleKeys.liveCouldnTCreatePost.tr,
        snackBarType: SnackBarType.Error,
      );
    }
  }
}
