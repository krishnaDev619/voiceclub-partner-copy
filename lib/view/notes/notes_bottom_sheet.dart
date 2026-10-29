import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pinput/pinput.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/get_notes_response.dart';
import 'package:voiceclub_partner/data/models/chat/note_model.dart';
import 'package:voiceclub_partner/domain/usecases/chat/add_chat_note.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_notes.dart'
    as get_chat_note;
import 'package:voiceclub_partner/domain/usecases/chat/update_custom_name.dart'
    as nickname;
import 'package:voiceclub_partner/view/notes/new_note_bottom_sheet.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/live_labels.dart';

class NotesBottomSheet extends StatefulWidget {
  final String userName;
  final int accountId;
  final String userNumber;
  final String screenName;
  final ChatTheme theme;
  final String? existingNickname;
  final Function(String) nicknameChangeCallback;

  const NotesBottomSheet({
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
  State<NotesBottomSheet> createState() => _NotesBottomSheetState();
}

class _NotesBottomSheetState extends State<NotesBottomSheet> {
  bool _shouldSave = false;
  MaritalStatus? selectedMaritalStatus;
  Profession? selectedProfession;
  TextEditingController ageController = TextEditingController();
  final nicknameController = TextEditingController();
  List<Note> notesList = [];

  @override
  void initState() {
    nicknameController.setText(widget.existingNickname ?? "");
    fetchNotes().then((value) {
      sl<AnalyticsService>().trackEvent(
        'partnerNotes',
        eventProperties: {
          'demandName': widget.userName,
          'demandNumber': widget.userNumber,
          'demandAccountId': widget.accountId,
          'screenName': widget.screenName,
          "existingNickname": widget.existingNickname,
          'notes': notesList.map((e) => e.text).toList(),
        },
      );
    });
    super.initState();
  }

  void initData(GetNotesResponseModel getNotesResponseModel) {
    setState(() {
      selectedMaritalStatus = getNotesResponseModel.relationship;
      selectedProfession = getNotesResponseModel.profession;
      ageController.setText((getNotesResponseModel.age ?? 0).toString());
      notesList = getNotesResponseModel.notes ?? [];
    });
  }

  Future<void> fetchNotes() async {
    try {
      Get.context?.loaderOverlay.show();
      var getNotesUseCase = sl<get_chat_note.GetChatNoteUseCase>();
      var response = await getNotesUseCase.call(
        get_chat_note.Params(accountId: widget.accountId),
      );
      if (response.data != null && response.error == null) {
        var getNotesResponseModel = response.data ?? GetNotesResponseModel();
        initData(getNotesResponseModel);
      }
    } catch (_) {
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  String formatDate(String date) {
    var dateTime = DateTime.parse(date);
    var formatter = DateFormat('EEE, dd MMM yyyy');
    return formatter.format(dateTime);
  }

  Future<void> saveNewNote(String? newNote) async {
    try {
      if (newNote?.isNotEmpty ?? false) {
        final response = await sl<AddChatNoteUseCase>().call(
          Params(
            accountId: widget.accountId,
            age: int.tryParse(ageController.text.trim()) ?? 0,
            profession: selectedProfession?.toDisplayName() ?? "",
            relationship: selectedMaritalStatus?.name ?? "",
            noteRequest: {"text": newNote ?? ""},
          ),
        );
        if (response.error == null) {
          fetchNotes();
          sl<AnalyticsService>().trackEvent(
            "partnerNewNoteAdded",
            eventProperties: {
              'demandName': widget.userName,
              'demandNumber': widget.userNumber,
              'demandAccountId': widget.accountId,
              'screenName': widget.screenName,
              'age': ageController.text.trim(),
              'relationship': selectedMaritalStatus?.name,
              'profession': selectedProfession?.toDisplayName(),
              'newNote': newNote,
            },
          );
        }
      }
    } catch (_) {}
  }

  Future<void> saveNotes() async {
    try {
      if (_shouldSave) {
        await updateNickname();
        var response = await sl<AddChatNoteUseCase>().call(
          Params(
            accountId: widget.accountId,
            age: int.tryParse(ageController.text.trim()) ?? 0,
            profession: selectedProfession?.toDisplayName() ?? "",
            relationship: selectedMaritalStatus?.name ?? "",
            noteRequest: const {"text": ""},
          ),
        );
        if (response.data != null && response.error == null) {
          sl<AnalyticsService>().trackEvent(
            "partnerNoteAdded",
            eventProperties: {
              'demandName': widget.userName,
              'demandNumber': widget.userNumber,
              'demandAccountId': widget.accountId,
              'screenName': widget.screenName,
              'age': ageController.text.trim(),
              'relationship': selectedMaritalStatus?.name,
              'profession': selectedProfession?.toDisplayName(),
            },
          );
        }
      }
    } catch (_) {}
  }

  Future<void> updateNickname() async {
    try {
      final newNickname = nicknameController.text.trim();
      if (newNickname.length >= 3 && newNickname != widget.existingNickname) {
        final response = await sl<nickname.UpdateCustomNameUseCase>().call(
          nickname.Params(name: newNickname, accountId: widget.accountId),
        );
        if (response.error == null) {
          sl<AnalyticsService>().trackEvent(
            "nicknameAdded",
            eventProperties: {
              "newNickname": newNickname,
              "existingNickname": widget.existingNickname,
              "demandName": widget.userName,
              "demandAccountId": widget.accountId,
            },
          );
          widget.nicknameChangeCallback(newNickname);
        }
      }
    } catch (_) {}
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    saveNotes();
    super.dispose();
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
                    LocaleKeys.liveNotesWith.trParams({
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
                              LocaleKeys.liveNickname.tr,
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
                                    _shouldSave = true;
                                  });
                                },
                                maxLines: 1,
                                maxLengthEnforcement:
                                    MaxLengthEnforcement.enforced,
                                decoration: InputDecoration(
                                  hintText: LocaleKeys.liveAddNickname.tr,
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
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  LocaleKeys.liveAge.tr,
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
                                      return null;
                                    },
                                    onChanged: (_) {
                                      setState(() {
                                        _shouldSave = true;
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
                                      contentPadding: EdgeInsets.only(
                                        bottom: 6.0,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    style: const TextStyle(
                                      fontSize: FontSize.L,
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
                                  LocaleKeys.liveRelationship.tr,
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
                                            _shouldSave = true;
                                          });
                                        }
                                      },
                                      value: selectedMaritalStatus,
                                      selectedItemBuilder: (context) {
                                        return MaritalStatus.values.map((ele) {
                                          return Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              liveMaritalLabel(ele),
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
                                      hint: Text(LocaleKeys.liveSelect.tr),
                                      alignment: Alignment.centerLeft,
                                      items:
                                          MaritalStatus.values.map((ele) {
                                            return DropdownMenuItem<
                                              MaritalStatus
                                            >(
                                              value: ele,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                liveMaritalLabel(ele),
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
                                  LocaleKeys.liveProfession.tr,
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
                                            _shouldSave = true;
                                          });
                                        }
                                      },
                                      value: selectedProfession,
                                      selectedItemBuilder: (context) {
                                        return Profession.values.map((ele) {
                                          return Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              liveProfessionLabel(ele),
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
                                      hint: Text(LocaleKeys.liveSelect.tr),
                                      alignment: Alignment.centerLeft,
                                      items:
                                          Profession.values.map((ele) {
                                            return DropdownMenuItem<Profession>(
                                              value: ele,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                liveProfessionLabel(ele),
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
                            saveNewNote(newNote);
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
                                LocaleKeys.liveAddANote.tr,
                                style: const TextStyle(
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
