// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDataModelAdapter extends TypeAdapter<UserDataModel> {
  @override
  final typeId = 6;

  @override
  UserDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserDataModel(
      id: (fields[0] as num?)?.toInt(),
      name: fields[1] as String?,
      phoneNumber: fields[2] as String?,
      avatar: fields[3] as String?,
      status: fields[4] as String?,
      fcmToken: fields[5] as String?,
      notificationPreference: fields[6] as String?,
      hasUpdatedName: fields[7] as bool?,
      hasUpdatedImage: fields[8] as bool?,
      tag: fields[9] as String?,
      role: fields[10] as AccountType?,
    );
  }

  @override
  void write(BinaryWriter writer, UserDataModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.fcmToken)
      ..writeByte(6)
      ..write(obj.notificationPreference)
      ..writeByte(7)
      ..write(obj.hasUpdatedName)
      ..writeByte(8)
      ..write(obj.hasUpdatedImage)
      ..writeByte(9)
      ..write(obj.tag)
      ..writeByte(10)
      ..write(obj.role);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
