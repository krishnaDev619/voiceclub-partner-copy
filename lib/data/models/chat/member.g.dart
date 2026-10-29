// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMemberAdapter extends TypeAdapter<ChatMember> {
  @override
  final typeId = 5;

  @override
  ChatMember read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMember(
      accountId: (fields[0] as num?)?.toInt(),
      user: fields[1] as UserDataModel?,
      accountType: fields[2] as String?,
      presence: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMember obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.accountId)
      ..writeByte(1)
      ..write(obj.user)
      ..writeByte(2)
      ..write(obj.accountType)
      ..writeByte(3)
      ..write(obj.presence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
