import 'package:flutter/material.dart';
import 'package:voiceclub_partner/data/models/chat/chat_filter_option.dart';

class DemoChatFilter {
  final String? name;
  final IconData? icon;
  final String? description;
  final int? order;
  final List<ChatFilterOption>? options;

  DemoChatFilter({
    this.name,
    this.icon,
    this.description,
    this.order,
    this.options,
  });
}
