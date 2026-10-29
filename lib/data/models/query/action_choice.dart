import 'package:flutter/material.dart';

class ActionChoice {
  // To be sent as content in the sendMessage API
  final String? label;
  final String? optionType;
  final int? externalId;
  final String? value;
  final String? color;

  ActionChoice({
    this.label,
    this.optionType,
    this.externalId,
    this.value,
    this.color,
  });

  ActionChoice.fromJson(Map<String, dynamic> json)
    : label = json['Label'] as String?,
      optionType = json['OptionType'] as String?,
      externalId = json['ExternalID'] as int?,
      value = json['Value'] as String?,
      color = json['Color'] as String?;

  Map<String, dynamic> toJson() => {
    'Value': value,
    'Color': color,
    'Label': label,
    'OptionType': optionType,
    'ExternalID': externalId,
  };

  Color get flutterColor {
    final parsed = _parseHexColor(color);
    return parsed ?? Colors.grey.shade500;
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null) return null;

    final normalized = hex.replaceAll('#', '').trim();
    if (normalized.length != 6 && normalized.length != 8) {
      return null;
    }

    final colorHex = normalized.length == 6 ? 'FF$normalized' : normalized;
    final value = int.tryParse(colorHex, radix: 16);

    if (value == null) return null;
    return Color(value);
  }
}
