import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? name;
  final IconData? icon;
  final EdgeInsets padding;
  final int? maxLength;
  final int? maxLines;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  const CustomTextField({
    super.key,
    this.controller,
    this.readOnly = false,
    this.inputFormatters,
    this.name,
    this.padding = const EdgeInsets.only(left: 10),
    this.icon,
    this.maxLength,
    this.maxLines,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 0.1, color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          icon == null ? const SizedBox.shrink() : const SizedBox(width: 10),
          icon == null
              ? const SizedBox.shrink()
              : CircleAvatar(
                radius: 16,
                backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.1),
                child: Icon(icon, size: 15, color: Get.theme.primaryColor),
              ),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              readOnly: readOnly,
              inputFormatters: inputFormatters,
              keyboardType: keyboardType,
              maxLength: maxLength,
              maxLines: maxLines ?? 1,
              maxLengthEnforcement:
                  maxLength != null ? MaxLengthEnforcement.enforced : null,
              controller: controller,
              decoration: InputDecoration(
                counterText: "",
                contentPadding: padding,
                fillColor: Colors.white,
                border: InputBorder.none,
                hintStyle: const TextStyle(fontSize: 13),
                hintText: name,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextFiledNormal extends StatelessWidget {
  final TextEditingController? controller;
  final String? name;
  final IconData? icon;
  final int? maxLength;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final bool readOnly;
  const CustomTextFiledNormal({
    super.key,
    this.controller,
    this.readOnly = false,
    this.name,
    this.icon,
    this.maxLength,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
      ),
      child: Row(
        children: [
          icon == null ? const SizedBox.shrink() : const SizedBox(width: 10),
          icon == null
              ? const SizedBox.shrink()
              : CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xff4E54D3).withValues(alpha: 0.1),
                child: Icon(icon, size: 15, color: const Color(0xff4E54D3)),
              ),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              readOnly: readOnly,
              keyboardType: keyboardType,
              maxLength: maxLength,
              controller: controller,
              decoration: InputDecoration(
                // prefix:
                contentPadding: const EdgeInsets.only(left: 10),
                fillColor: Colors.white,
                border: InputBorder.none,
                hintStyle: const TextStyle(fontSize: 13),
                hintText: name,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
