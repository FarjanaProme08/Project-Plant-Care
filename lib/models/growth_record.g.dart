// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GrowthRecordAdapter extends TypeAdapter<GrowthRecord> {
  @override
  final int typeId = 2;

  @override
  GrowthRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GrowthRecord(
      id: fields[0] as String,
      plantId: fields[1] as String,
      imagePath: fields[2] as String,
      date: fields[3] as DateTime,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GrowthRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.plantId)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrowthRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
