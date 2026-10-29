import 'package:equatable/equatable.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/chat/chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/chat_pricing.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';

part 'chat_group.g.dart';

@HiveType(typeId: 0)
class ChatGroup extends Equatable {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final CategoryCode? category;
  @HiveField(2)
  final ChatMessage? lastMessage;
  @HiveField(3)
  final String? lastMessageAt;
  @HiveField(4)
  final String? title;
  @HiveField(5)
  final int? unseenCount;
  @HiveField(6)
  final ChatTier? tier;
  @HiveField(7)
  final bool? isLocked;
  @HiveField(8)
  final bool? isBlocked;
  @HiveField(9)
  final bool? isPinned;
  @HiveField(10)
  final List<ChatMember>? members;
  @HiveField(11)
  final ChatPricing? pricing;
  @HiveField(12)
  final bool? isSubscriptionActive;
  @HiveField(13)
  final String? subscriptionEndDate;
  @HiveField(14)
  final String? customName;
  @HiveField(15)
  final String? chatThemeId;

  const ChatGroup({
    this.id,
    this.category,
    this.lastMessage,
    this.lastMessageAt,
    this.title,
    this.unseenCount,
    this.tier,
    this.members,
    this.isPinned,
    this.isBlocked,
    this.isLocked,
    this.pricing,
    this.isSubscriptionActive,
    this.subscriptionEndDate,
    this.customName,
    this.chatThemeId = defaultThemeId,
  });

  ChatGroup.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      category = (json['category'] as String? ?? '').toCategoryCode(),
      lastMessage =
          (json['last_message'] as Map<String, dynamic>?) != null
              ? ChatMessage.fromJson(
                json['last_message'] as Map<String, dynamic>,
              )
              : null,
      lastMessageAt = json['last_message_at'] as String?,
      title = json['title'] as String?,
      unseenCount = json['unseen_count'] as int?,
      tier = (json['tier'] as String? ?? '').toChatTier(),
      isPinned = json['is_pinned'] as bool?,
      isLocked = json['is_locked'] as bool?,
      isBlocked = json['is_blocked'] as bool?,
      members =
          (json['members'] as List?)
              ?.map(
                (dynamic e) => ChatMember.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      pricing =
          (json['pricing'] as Map<String, dynamic>?) != null
              ? ChatPricing.fromJson(json['pricing'] as Map<String, dynamic>)
              : null,
      isSubscriptionActive = json['is_subscription_active'] as bool?,
      subscriptionEndDate = json['subscription_end_date'] as String?,
      chatThemeId = json['chatTheme'] as String?,
      customName = json['custom_name'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'last_message': lastMessage?.toJson(),
    'last_message_at': lastMessageAt,
    'title': title,
    'unseen_count': unseenCount,
    'tier': tier.toString(),
    'is_locked': isLocked,
    'is_blocked': isBlocked,
    'is_pinned': isPinned,
    'members': members?.map((e) => e.toJson()).toList(),
    'pricing': pricing?.toJson(),
    'is_subscription_active': isSubscriptionActive,
    'subscription_end_date': subscriptionEndDate,
    'custom_name': customName,
    'chatTheme': chatThemeId,
  };

  @override
  List<Object?> get props => [id, lastMessageAt, tier?.name, unseenCount];

  ChatGroup copyWith({String? chatThemeId}) {
    return ChatGroup(
      id: id,
      category: category,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      title: title,
      unseenCount: unseenCount,
      tier: tier,
      isPinned: isPinned,
      isBlocked: isBlocked,
      isLocked: isLocked,
      members: members,
      pricing: pricing,
      isSubscriptionActive: isSubscriptionActive,
      subscriptionEndDate: subscriptionEndDate,
      customName: customName,
      chatThemeId: chatThemeId ?? this.chatThemeId,
    );
  }

  ChatTheme get chatTheme => defaultTheme;
}
