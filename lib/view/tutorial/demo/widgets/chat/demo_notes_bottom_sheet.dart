import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/note_model.dart';
import 'package:voiceclub_partner/view/notes/new_note_bottom_sheet.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/tutorial/demo/demo_labels.dart';

class DemoNotesBottomSheet extends StatefulWidget {
  final String userName;
  final int accountId;
  final String userNumber;
  final String screenName;
  final ChatTheme theme;
  final String? existingNickname;
  final Function(String) nicknameChangeCallback;

  const DemoNotesBottomSheet({
    super.key,
    required this.userName,
    required this.accountId,
    required this.userNumber,
    required this.screenName,
    required this.theme,
    required this.existingNickname,
    required this.nicknameChangeCallback,
  });

  @override
  State<DemoNotesBottomSheet> createState() => _DemoNotesBottomSheetState();
}

class _DemoNotesBottomSheetState extends State<DemoNotesBottomSheet> {
  // bool _shouldSave = false;
  MaritalStatus? selectedMaritalStatus;
  Profession? selectedProfession;
  TextEditingController ageController = TextEditingController();
  final nicknameController = TextEditingController();
  List<Note> notesList = [];

  @override
  void initState() {
    super.initState();
    nicknameController.setText(widget.existingNickname ?? "");
  }

  void initData() {
    setState(() {
      selectedMaritalStatus = MaritalStatus.Unmarried;
      selectedProfession = Profession.Driver;
      ageController.setText("23");
      notesList = [];
    });
  }

  String formatDate(String date) {
    var dateTime = DateTime.parse(date);
    var formatter = DateFormat('EEE, dd MMM yyyy');
    return formatter.format(dateTime);
  }

  Future<void> saveNewNote({String? newNote}) async {
    try {
      FocusScope.of(context).unfocus();
      updateNickname();
      if (newNote != null) {
        notesList.add(
          Note(text: newNote, createdAt: DateTime.now().toString()),
        );
        Get.find<DemoLandingController>().validateAction(
          TutorialDemoFeature.CHAT_NOTES,
        );
      } else {
        Get.back();
      }
    } catch (_) {}
  }

  void updateNickname() {
    try {
      final newNickname = nicknameController.text.trim();
      if (newNickname.length >= 3 && newNickname != widget.existingNickname) {
        widget.nicknameChangeCallback(newNickname);
      }
    } catch (_) {}
  }

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
        child: SingleChildScrollView(
          child: TapToUnFocus(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 10.0,
                  ),
                  child: Text(
                    LocaleKeys.demoNotesWith.trParams({
                      'name': widget.userName,
                    }),
                    style: const TextStyle(
                      fontWeight: Weight.heavy,
                      fontSize: FontSize.xXL,
                    ),
                  ),
                ),
                const Divider(
                  thickness: 1.0,
                  height: 4.0,
                  indent: 12.0,
                  endIndent: 12.0,
                ),
                const SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              LocaleKeys.demoNickname.tr,
                              style: TextStyle(
                                fontSize: FontSize.L,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            flex: 9,
                            child: Container(
                              height: 42.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: TextField(
                                controller: nicknameController,
                                maxLength: 16,
                                buildCounter: (
                                  BuildContext context, {
                                  int? currentLength,
                                  bool? isFocused,
                                  int? maxLength,
                                }) {
                                  return null; // This hides the counter text
                                },
                                onChanged: (_) {
                                  setState(() {
                                    // _shouldSave = true;
                                  });
                                },
                                maxLines: 1,
                                maxLengthEnforcement:
                                    MaxLengthEnforcement.enforced,
                                decoration: InputDecoration(
                                  hintText: LocaleKeys.demoAddNickname.tr,
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                  contentPadding: EdgeInsets.only(bottom: 6.0),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: FontSize.L),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              LocaleKeys.demoAge.tr,
                              style: TextStyle(
                                fontSize: FontSize.L,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            flex: 9,
                            child: Container(
                              height: 42.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: TextField(
                                controller: ageController,
                                maxLength: 2,
                                keyboardType: TextInputType.number,
                                buildCounter: (
                                  BuildContext context, {
                                  int? currentLength,
                                  bool? isFocused,
                                  int? maxLength,
                                }) {
                                  return null; // This hides the counter text
                                },
                                onChanged: (_) {
                                  setState(() {
                                    // _shouldSave = true;
                                  });
                                },
                                maxLines: 1,
                                maxLengthEnforcement:
                                    MaxLengthEnforcement.enforced,
                                decoration: const InputDecoration(
                                  hintText: "XX",
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                  contentPadding: EdgeInsets.only(bottom: 6.0),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(fontSize: FontSize.L),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              LocaleKeys.demoRelationship.tr,
                              style: TextStyle(
                                fontSize: FontSize.L,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            flex: 9,
                            child: Container(
                              height: 42.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  padding: const EdgeInsets.all(0.0),
                                  isExpanded: true,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedMaritalStatus = value;
                                        // _shouldSave = true;
                                      });
                                    }
                                  },
                                  value: selectedMaritalStatus,
                                  selectedItemBuilder: (context) {
                                    return MaritalStatus.values.map((ele) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          demoMaritalLabel(ele),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: FontSize.L,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  },
                                  hint: Text(LocaleKeys.demoSelect.tr),
                                  alignment: Alignment.centerLeft,
                                  items:
                                      MaritalStatus.values.map((ele) {
                                        return DropdownMenuItem<MaritalStatus>(
                                          value: ele,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            demoMaritalLabel(ele),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              LocaleKeys.demoProfession.tr,
                              style: TextStyle(
                                fontSize: FontSize.L,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            flex: 9,
                            child: Container(
                              height: 42.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  padding: const EdgeInsets.all(0.0),
                                  isExpanded: true,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedProfession = value;
                                        // _shouldSave = true;
                                      });
                                    }
                                  },
                                  value: selectedProfession,
                                  selectedItemBuilder: (context) {
                                    return Profession.values.map((ele) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          demoProfessionLabel(ele),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: FontSize.L,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  },
                                  hint: Text(LocaleKeys.demoSelect.tr),
                                  alignment: Alignment.centerLeft,
                                  items:
                                      Profession.values.map((ele) {
                                        return DropdownMenuItem<Profession>(
                                          value: ele,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            demoProfessionLabel(ele),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14.0),
                      GestureDetector(
                        onTap: () async {
                          final newNote = await Get.bottomSheet<String?>(
                            const NewNoteBottomSheet(),
                            isScrollControlled: true,
                          );
                          if (newNote?.isNotEmpty ?? false) {
                            saveNewNote(newNote: newNote);
                          }
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.theme.primaryColor.withValues(
                                    alpha: 0.10,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.add,
                                  color: widget.theme.primaryColor,
                                  size: 22.0,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Text(
                                LocaleKeys.demoAddNote.tr,
                                style: TextStyle(
                                  fontSize: FontSize.L,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black26,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14.0),
                      if (notesList.isNotEmpty)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 20.0,
                            maxHeight: Get.height * 0.5,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(bottom: 14.0),
                            itemBuilder: (context, index) {
                              return Container(
                                alignment: Alignment.centerLeft,
                                margin: const EdgeInsets.only(bottom: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 8.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formatDate(
                                        notesList[index].createdAt ?? "",
                                      ),
                                      style: const TextStyle(
                                        fontWeight: Weight.heavy,
                                        fontSize: FontSize.L,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(notesList[index].text ?? ""),
                                  ],
                                ),
                              );
                            },
                            itemCount: notesList.length,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TapToUnFocus extends StatelessWidget {
  final Widget child;

  const TapToUnFocus({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: child,
    );
  }
}
