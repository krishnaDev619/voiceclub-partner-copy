import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

import '../../broadcast/widgets/broadcast_action_bottom_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class AddQuickReplyBottomSheet extends StatefulWidget {
  const AddQuickReplyBottomSheet({super.key});

  @override
  State<AddQuickReplyBottomSheet> createState() =>
      _AddQuickReplyBottomSheetState();
}

class _AddQuickReplyBottomSheetState extends State<AddQuickReplyBottomSheet> {
  final quickReplyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StatefulBuilder(
        builder: (context, setContainerState) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              color: Color(0xFFF9F9F9),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Add Quick Reply",
                    style: TextStyle(
                      fontWeight: Weight.heavy,
                      fontSize: FontSize.xXL,
                    ),
                  ),
                ),
                const Divider(thickness: 2.0, height: 4.0),
                const SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          color: Colors.white,
                          child: TextField(
                            controller: quickReplyController,
                            maxLength: 280,
                            onChanged: (_) {
                              setContainerState(() {});
                            },
                            maxLines: 3,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            decoration: InputDecoration(
                              counterText:
                                  (quickReplyController.text.length < min &&
                                          quickReplyController.text.isNotEmpty)
                                      ? "${quickReplyController.text.length.toString()}/$min"
                                      : "",
                              hintText:
                                  LocaleKeys.liveTypeYourQuickReplyHere.tr,
                              isCollapsed: true,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 10.0,
                              ),
                              fillColor: Colors.white,
                              border: InputBorder.none,
                              hintStyle: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      CustomButton(
                        text: LocaleKeys.liveSave.tr,
                        enabled: quickReplyController.text.length >= min,
                        onTap: () {
                          Get.back(result: quickReplyController.text.trim());
                        },
                      ),
                      const SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
