import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallNotesButton extends StatelessWidget {
  final bool isCallAccepted;
  final String demandName;
  final int? demandAccountId;
  final VoidCallback openNotesFunction;
  const CallNotesButton({
    super.key,
    required this.isCallAccepted,
    required this.demandName,
    required this.demandAccountId,
    required this.openNotesFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.only(right: 16.0, top: 16.0),
        height: 48.0,
        child: Visibility(
          visible: isCallAccepted,
          child: GestureDetector(
            onTap: openNotesFunction,
            child: Icon(Icons.note_alt_outlined, color: Get.theme.primaryColor),
          ),
        ),
      ),
    );
  }
}
