// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charity_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CharityDonationAdapter extends TypeAdapter<CharityDonation> {
  @override
  final int typeId = 10;

  @override
  CharityDonation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CharityDonation(
      id: fields[0] as String,
      amount: fields[1] as double,
      categoryIndex: fields[2] as int,
      date: fields[3] as DateTime,
      notes: fields[4] as String?,
      currency: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CharityDonation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.categoryIndex)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.currency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharityDonationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringCharityAdapter extends TypeAdapter<RecurringCharity> {
  @override
  final int typeId = 21;

  @override
  RecurringCharity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringCharity(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      categoryIndex: fields[3] as int,
      dayOfMonth: fields[4] as int,
      isActive: fields[5] as bool,
      currency: fields[6] as String,
      lastDonatedDate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringCharity obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.categoryIndex)
      ..writeByte(4)
      ..write(obj.dayOfMonth)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.currency)
      ..writeByte(7)
      ..write(obj.lastDonatedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringCharityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
