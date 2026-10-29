import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/unsplash/unsplash_photo.dart';
import 'package:voiceclub_partner/domain/usecases/social/create_post.dart';
import 'package:voiceclub_partner/domain/usecases/unsplash/search_photos.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CreateImagePostController extends GetxController {
  final RxString selectedCategory = 'Good Morning'.obs;
  final RxList<UnsplashPhoto> images = <UnsplashPhoto>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;

  final List<UnsplashCategory> categories = [
    UnsplashCategory(
      name: 'Good Morning',
      icon: '☀️',
      pretext: 'Good morning! 🌞',
    ),
    UnsplashCategory(name: 'Good Night', icon: '🌙', pretext: 'Good night! 🌙'),
    UnsplashCategory(
      name: 'Lonely',
      icon: '😔',
      pretext: 'It is okay to be alone. 💪',
    ),
    UnsplashCategory(
      name: 'Relationship',
      icon: '💑',
      pretext: 'Love is real. ❤️',
    ),
    UnsplashCategory(name: 'Funny', icon: '😂', pretext: 'Laugh it off! 😂'),
    UnsplashCategory(
      name: 'Breakup',
      icon: '💔',
      pretext: 'New beginnings ahead! 🌟',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchImages();
  }

  Future<void> fetchImages() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      final query =
          selectedCategory.value == 'All'
              ? 'nature,landscape'
              : selectedCategory.value;
      final response = await sl<SearchPhotosUsecase>().call(
        SearchPhotosParams(query: query, page: currentPage.value, perPage: 20),
      );

      if (response.data?.results?.isNotEmpty == true) {
        final data = response.data!;
        final List<UnsplashPhoto> newImages =
            data.results!.map((image) {
              return UnsplashPhoto(
                id: image.id ?? "",
                url: image.url ?? "",
                thumbUrl: image.thumbUrl ?? "",
                description: image.description ?? '',
              );
            }).toList();

        newImages.shuffle();

        if (currentPage.value == 1) {
          images.value = newImages;
        } else {
          images.addAll(newImages);
        }
        if (currentPage.value < (data.totalPages ?? 0)) {
          currentPage.value++;
        }
      }
    } catch (e) {
      Logger.logMessage(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void changeCategory(String category, String pretext) {
    if (selectedCategory.value != category) {
      selectedCategory.value = category;
      text.value = pretext;
      currentPage.value = 1;
      fetchImages();
    }
  }

  Future<void> loadMore() async {
    await fetchImages();
  }

  final Rx<Color> selectedColor = Colors.white.obs;
  final RxString text = 'Good morning! 🌞'.obs;
  final RxDouble fontSize = 24.0.obs;
  final RxString selectedFont = 'Roboto'.obs;
  final RxBool isUploading = false.obs;

  final List<Color> availableColors = [
    const Color(0xFFFFFFFF), // Pure white for maximum contrast
    const Color(0xFFFFE5B4), // Peach for warmth
    const Color(0xFFE6E6FA), // Lavender for elegance
    const Color(0xFFFFB6C1), // Light pink for softness
    const Color(0xFFB0E0E6), // Powder blue for calmness
    const Color(0xFFFFF0F5), // Lavender blush for subtlety
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
      color: selectedColor.value,
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

  Future<void> publishPost(
    final UnsplashPhoto photo,
    final String? text,
  ) async {
    try {
      isUploading.value = true;
      final response = await sl<CreatePostUsecase>().call(
        CreatePostParams(
          postType: PostMediaType.IMAGE,
          textContent: text?.trim() ?? '',
          mediaUrl: photo.url ?? '',
          postColor: selectedColor.value.toHex(),
          fontStyle: selectedFont.value,
          textOverlay: text?.trim() ?? '',
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
            "postType": PostMediaType.IMAGE.name,
            "imageCategory": selectedCategory.value,
            "postText": text?.trim() ?? '',
            "postId": response.data?.postId,
          },
        );
        Get.until((route) => route.isFirst);
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

class UnsplashCategory {
  final String name;
  final String icon;
  final String pretext;

  UnsplashCategory({
    required this.name,
    required this.icon,
    required this.pretext,
  });
}
