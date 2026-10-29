// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatGroupAdapter extends TypeAdapter<ChatGroup> {
  @override
  final typeId = 0;

  @override
  ChatGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatGroup(
      id: (fields[0] as num?)?.toInt(),
      category: fields[1] as CategoryCode?,
      lastMessage: fields[2] as ChatMessage?,
      lastMessageAt: fields[3] as String?,
      title: fields[4] as String?,
      unseenCount: (fields[5] as num?)?.toInt(),
      tier: fields[6] as ChatTier?,
      members: (fields[10] as List?)?.cast<ChatMember>(),
      isPinned: fields[9] as bool?,
      isBlocked: fields[8] as bool?,
      isLocked: fields[7] as bool?,
      pricing: fields[11] as ChatPricing?,
      isSubscriptionActive: fields[12] as bool?,
      subscriptionEndDate: fields[13] as String?,
      customName: fields[14] as String?,
      chatThemeId: fields[15] == null ? defaultThemeId : fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatGroup obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.lastMessage)
      ..writeByte(3)
      ..write(obj.lastMessageAt)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.unseenCount)
      ..writeByte(6)
      ..write(obj.tier)
      ..writeByte(7)
      ..write(obj.isLocked)
      ..writeByte(8)
      ..write(obj.isBlocked)
      ..writeByte(9)
      ..write(obj.isPinned)
      ..writeByte(10)
      ..write(obj.members)
      ..writeByte(11)
      ..write(obj.pricing)
      ..writeByte(12)
      ..write(obj.isSubscriptionActive)
      ..writeByte(13)
      ..write(obj.subscriptionEndDate)
      ..writeByte(14)
      ..write(obj.customName)
      ..writeByte(15)
      ..write(obj.chatThemeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
