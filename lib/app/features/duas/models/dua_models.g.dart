// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dua_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomDuaAdapter extends TypeAdapter<CustomDua> {
  @override
  final int typeId = 14;

  @override
  CustomDua read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomDua(
      id: fields[0] as String,
      title: fields[1] as String,
      arabic: fields[2] as String,
      notes: fields[3] as String?,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomDua obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.arabic)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomDuaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DuaReminderAdapter extends TypeAdapter<DuaReminder> {
  @override
  final int typeId = 15;

  @override
  DuaReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DuaReminder(
      id: fields[0] as String,
      duaId: fields[1] as String,
      title: fields[2] as String,
      hour: fields[3] as int,
      minute: fields[4] as int,
      weekdays: (fields[5] as List).cast<int>(),
      isActive: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DuaReminder obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.duaId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.hour)
      ..writeByte(4)
      ..write(obj.minute)
      ..writeByte(5)
      ..write(obj.weekdays)
      ..writeByte(6)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuaReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
