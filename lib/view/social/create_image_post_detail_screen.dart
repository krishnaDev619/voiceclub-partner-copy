import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/unsplash/unsplash_photo.dart';
import 'package:voiceclub_partner/view/social/controllers/create_image_post_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CreateImagePostDetailScreen extends StatefulWidget {
  final UnsplashPhoto photo;

  const CreateImagePostDetailScreen({super.key, required this.photo});

  @override
  State<CreateImagePostDetailScreen> createState() =>
      _CreateImagePostDetailScreenState();
}

class _CreateImagePostDetailScreenState
    extends State<CreateImagePostDetailScreen> {
  final controller = Get.find<CreateImagePostController>();
  final FocusNode _focusNode = FocusNode();
  bool _isKeyboardVisible = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _textController.text = controller.text.value;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.value.length),
    );
    sl<AnalyticsService>().trackEvent(
      "newPostInitiatePartner",
      eventProperties: {"postType": PostMediaType.IMAGE.name},
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 56.0,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Color selection buttons
                for (Color color in controller.availableColors)
                  GestureDetector(
                    onTap: () => controller.updateColor(color),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              controller.selectedColor.value == color
                                  ? Colors.black
                                  : Colors.black12,
                          width:
                              controller.selectedColor.value == color ? 2 : 1,
                        ),
                      ),
                      child: CircleAvatar(backgroundColor: color, radius: 10),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            _buildPostButton(
              onTap:
                  controller.isUploading.value
                      ? null
                      : () => controller.publishPost(
                        widget.photo,
                        _textController.text,
                      ),
              isLoading: controller.isUploading.value,
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                // Square preview container with image and overlay
                Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () {
                      if (!_focusNode.hasFocus) {
                        _focusNode.requestFocus();
                      }
                    },
                    child: Container(
                      width: Get.width,
                      height: Get.width,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          image: FastCachedImageProvider(
                            widget.photo.url ?? '',
                          ),
                          colorFilter:
                              _textController.text.isEmpty
                                  ? null
                                  : ColorFilter.mode(
                                    Colors.black.withValues(alpha: 0.7),
                                    BlendMode.darken,
                                  ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: TextField(
                        controller: _textController,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        focusNode: _focusNode,
                        onChanged: (value) {
                          controller.updateText(value);
                          setState(() {});
                        },
                        style: TextStyle(
                          color: controller.selectedColor.value,
                          fontSize: controller.getCurrentFontStyle().fontSize,
                          fontFamily:
                              controller.getCurrentFontStyle().fontFamily,
                          fontWeight:
                              controller.getCurrentFontStyle().fontWeight,
                          height: 1.2,
                        ),
                        cursorColor: controller.selectedColor.value,
                        cursorWidth: 2,
                        cursorHeight:
                            controller.getCurrentFontStyle().fontSize! * 1.2,
                        maxLength: 280,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counter: const SizedBox.shrink(),
                          hintText: LocaleKeys.liveTypeSomething.tr,
                          hintStyle: TextStyle(
                            color: controller.selectedColor.value.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Font selector (only visible when keyboard is not open)
                if (!_isKeyboardVisible)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 42,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.availableFonts.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final font = controller.availableFonts[index];
                          return GestureDetector(
                            onTap: () => controller.updateFont(font['name']),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color:
                                    controller.selectedFont.value ==
                                            font['name']
                                        ? ApplicationColors.primaryRed
                                        : Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                'Aa',
                                textAlign: TextAlign.center,
                                style: font['style'](
                                  fontSize: 18.0,
                                  color:
                                      controller.selectedFont.value ==
                                              font['name']
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostButton({
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: !isLoading ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Container(
            height: 32,
            width: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color:
                  !isLoading
                      ? Get.theme.primaryColor
                      : Get.theme.primaryColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child:
                  isLoading
                      ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                      : Text(
                        'Post',
                        style: TextStyle(
                          color:
                              !isLoading
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
