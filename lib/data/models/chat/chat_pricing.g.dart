// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_pricing.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatPricingAdapter extends TypeAdapter<ChatPricing> {
  @override
  final typeId = 7;

  @override
  ChatPricing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatPricing(
      id: (fields[0] as num?)?.toInt(),
      price: (fields[1] as num?)?.toInt(),
      cta: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatPricing obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.price)
      ..writeByte(2)
      ..write(obj.cta);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatPricingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
