// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final typeId = 3;

  @override
  ChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessage(
      id: (fields[0] as num?)?.toInt(),
      senderAccountId: (fields[1] as num?)?.toInt(),
      content: fields[2] as String?,
      attachmentUrl: fields[3] as String?,
      type: fields[4] as ChatType?,
      linkedItemId: (fields[5] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.senderAccountId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.attachmentUrl)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.linkedItemId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
