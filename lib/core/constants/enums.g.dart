// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountTypeAdapter extends TypeAdapter<AccountType> {
  @override
  final typeId = 8;

  @override
  AccountType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AccountType.DEMAND;
      case 1:
        return AccountType.SUPPLY;
      default:
        return AccountType.DEMAND;
    }
  }

  @override
  void write(BinaryWriter writer, AccountType obj) {
    switch (obj) {
      case AccountType.DEMAND:
        writer.writeByte(0);
      case AccountType.SUPPLY:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryCodeAdapter extends TypeAdapter<CategoryCode> {
  @override
  final typeId = 1;

  @override
  CategoryCode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CategoryCode.GOSSIP;
      default:
        return CategoryCode.GOSSIP;
    }
  }

  @override
  void write(BinaryWriter writer, CategoryCode obj) {
    switch (obj) {
      case CategoryCode.GOSSIP:
        writer.writeByte(0);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryCodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatTypeAdapter extends TypeAdapter<ChatType> {
  @override
  final typeId = 2;

  @override
  ChatType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChatType.ChatTypeAudio;
      case 1:
        return ChatType.ChatTypeAudioNotification;
      case 2:
        return ChatType.ChatTypeNotification;
      case 3:
        return ChatType.ChatTypeText;
      case 4:
        return ChatType.ChatTypeGift;
      case 5:
        return ChatType.ChatTypeStoryReply;
      case 6:
        return ChatType.ChatTypeImage;
      case 7:
        return ChatType.ChatTypeVideo;
      case 8:
        return ChatType.ChatTypeMissedCall;
      case 9:
        return ChatType.ChatTypeCall;
      case 10:
        return ChatType.ChatTypeSticker;
      case 11:
        return ChatType.ChatTypeViewedCall;
      case 12:
        return ChatType.ChatTypePrivacyPack;
      case 13:
        return ChatType.ChatTypePostComment;
      case 14:
        return ChatType.ChatTypeGame;
      case 15:
        return ChatType.ChatTypeStoryComment;
      case 16:
        return ChatType.ChatTypeStoryReaction;
      default:
        return ChatType.ChatTypeAudio;
    }
  }

  @override
  void write(BinaryWriter writer, ChatType obj) {
    switch (obj) {
      case ChatType.ChatTypeAudio:
        writer.writeByte(0);
      case ChatType.ChatTypeAudioNotification:
        writer.writeByte(1);
      case ChatType.ChatTypeNotification:
        writer.writeByte(2);
      case ChatType.ChatTypeText:
        writer.writeByte(3);
      case ChatType.ChatTypeGift:
        writer.writeByte(4);
      case ChatType.ChatTypeStoryReply:
        writer.writeByte(5);
      case ChatType.ChatTypeImage:
        writer.writeByte(6);
      case ChatType.ChatTypeVideo:
        writer.writeByte(7);
      case ChatType.ChatTypeMissedCall:
        writer.writeByte(8);
      case ChatType.ChatTypeCall:
        writer.writeByte(9);
      case ChatType.ChatTypeSticker:
        writer.writeByte(10);
      case ChatType.ChatTypeViewedCall:
        writer.writeByte(11);
      case ChatType.ChatTypePrivacyPack:
        writer.writeByte(12);
      case ChatType.ChatTypePostComment:
        writer.writeByte(13);
      case ChatType.ChatTypeGame:
        writer.writeByte(14);
      case ChatType.ChatTypeStoryComment:
        writer.writeByte(15);
      case ChatType.ChatTypeStoryReaction:
        writer.writeByte(16);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatTierAdapter extends TypeAdapter<ChatTier> {
  @override
  final typeId = 4;

  @override
  ChatTier read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChatTier.PRO;
      case 1:
        return ChatTier.PREMIUM;
      default:
        return ChatTier.PRO;
    }
  }

  @override
  void write(BinaryWriter writer, ChatTier obj) {
    switch (obj) {
      case ChatTier.PRO:
        writer.writeByte(0);
      case ChatTier.PREMIUM:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatTierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
