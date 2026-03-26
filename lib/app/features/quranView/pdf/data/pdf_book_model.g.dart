// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_book_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdfBookModelAdapter extends TypeAdapter<PdfBookModel> {
  @override
  final int typeId = 30;

  @override
  PdfBookModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PdfBookModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      url: fields[3] as String,
      fileName: fields[5] as String,
      coverUrl: fields[4] as String?,
      isDownloaded: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PdfBookModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.coverUrl)
      ..writeByte(5)
      ..write(obj.fileName)
      ..writeByte(6)
      ..write(obj.isDownloaded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfBookModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
