// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'khatmah_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KhatmahModelAdapter extends TypeAdapter<KhatmahModel> {
  @override
  final int typeId = 0;

  @override
  KhatmahModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KhatmahModel(
      id: fields[0] as String,
      title: fields[1] as String,
      totalPages: fields[2] as int,
      currentPage: fields[3] as int,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime,
      dailyPages: fields[7] as int,
      isCompleted: fields[6] as bool,
      progressDates: (fields[8] as List?)?.cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, KhatmahModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.totalPages)
      ..writeByte(3)
      ..write(obj.currentPage)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.dailyPages)
      ..writeByte(8)
      ..write(obj.progressDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KhatmahModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
