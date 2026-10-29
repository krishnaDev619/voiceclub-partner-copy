import 'package:voiceclub_partner/data/models/chat/chat_filter_option.dart';

class ChatFilter {
  final String? name;
  final String? icon;
  final String? description;
  final int? order;
  final List<ChatFilterOption>? options;

  ChatFilter({
    this.name,
    this.icon,
    this.description,
    this.order,
    this.options,
  });

  ChatFilter.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String?,
      icon = json['icon'] as String?,
      description = json['description'] as String?,
      order = json['order'] as int?,
      options =
          (json['options'] as List?)
              ?.map(
                (dynamic e) =>
                    ChatFilterOption.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'name': name,
    'icon': icon,
    'description': description,
    'order': order,
    'options': options?.map((e) => e.toJson()).toList(),
  };

  String get filterCode =>
      options?.isNotEmpty ?? false ? options?.first.code ?? '' : '';

  String get filterName =>
      options?.isNotEmpty ?? false ? options?.first.name ?? '' : '';
}
