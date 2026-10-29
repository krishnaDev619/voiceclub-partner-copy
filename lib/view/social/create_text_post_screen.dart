import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/view/social/controllers/create_text_post_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CreateTextPostScreen extends StatefulWidget {
  const CreateTextPostScreen({super.key});

  @override
  State<CreateTextPostScreen> createState() => _CreateTextPostScreenState();
}

class _CreateTextPostScreenState extends State<CreateTextPostScreen> {
  final controller = Get.put(CreateTextPostController());
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
      eventProperties: {"postType": PostMediaType.TEXT.name},
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
        backgroundColor: controller.selectedColor.value,
        appBar: AppBar(
          backgroundColor: controller.selectedColor.value,
          toolbarHeight: 56.0,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
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
                                  ? Colors.white
                                  : Colors.transparent,
                          width: 2,
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
                      : () => controller.publishPost(),
              isLoading: controller.isUploading.value,
            ),
          ],
        ),
        body: Container(
          color: controller.selectedColor.value,
          child: Stack(
            children: [
              // Square preview container
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
                    color: controller.selectedColor.value,
                    alignment: Alignment.center,
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
                        color: Colors.white,
                        fontSize: controller.getCurrentFontStyle().fontSize,
                        fontFamily: controller.getCurrentFontStyle().fontFamily,
                        fontWeight: controller.getCurrentFontStyle().fontWeight,
                        height: 1.2, // Match line height with visible text
                      ),
                      cursorColor: _getContrastingTextColor(
                        controller.selectedColor.value,
                      ),
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
                          color: Colors.white.withValues(alpha: 0.3),
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
                                  controller.selectedFont.value == font['name']
                                      ? Colors.white
                                      : Colors.white24,
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
                                        ? controller.selectedColor.value
                                        : Colors.white,
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
    );
  }

  Color _getContrastingTextColor(Color backgroundColor) {
    // Calculate the perceived brightness of the background color
    double brightness =
        (backgroundColor.r * 299 +
            backgroundColor.g * 587 +
            backgroundColor.b * 114) /
        1000;

    // Return black for light backgrounds and white for dark backgrounds
    return brightness > 128 ? Colors.black : Colors.white;
  }

  Widget _buildPostButton({
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final bool isEnabled = controller.text.value.length >= 25 && !isLoading;

    return GestureDetector(
      onTap:
          isEnabled
              ? onTap
              : () {
                if (controller.text.value.length < 25) {
                  AlertService.showSnackBar(
                    snackBarType: SnackBarType.Warning,
                    title: LocaleKeys.liveMinimumLengthRequired.tr,
                    subtitle: LocaleKeys.livePleaseEnterAtLeast25.tr,
                  );
                }
              },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Container(
            height: 32,
            width: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isEnabled
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child:
                  isLoading
                      ? SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          color: controller.selectedColor.value,
                          strokeWidth: 2.0,
                        ),
                      )
                      : Text(
                        'Post',
                        style: TextStyle(
                          color:
                              isEnabled
                                  ? controller.selectedColor.value
                                  : controller.selectedColor.value.withValues(
                                    alpha: 0.5,
                                  ),
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
