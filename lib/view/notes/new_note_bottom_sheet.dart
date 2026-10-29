import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class NewNoteBottomSheet extends StatefulWidget {
  const NewNoteBottomSheet({super.key});

  @override
  State<NewNoteBottomSheet> createState() => _NewNoteBottomSheetState();
}

class _NewNoteBottomSheetState extends State<NewNoteBottomSheet> {
  final newNoteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                LocaleKeys.liveWriteNewNote.tr,
                style: const TextStyle(
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
                        controller: newNoteController,
                        minLines: 4,
                        maxLines: 10,
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: LocaleKeys.liveWriteYourNoteHere.tr,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  CustomButton(
                    text: LocaleKeys.liveSave.tr,
                    enabled: newNoteController.text.isNotEmpty,
                    onTap: () {
                      Get.back(result: newNoteController.text.trim());
                    },
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
