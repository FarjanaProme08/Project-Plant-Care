// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantAdapter extends TypeAdapter<Plant> {
  @override
  final int typeId = 0;

  @override
  Plant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plant(
      id: fields[0] as String,
      name: fields[1] as String,
      species: fields[2] as String,
      imagePath: fields[3] as String?,
      waterIntervalDays: fields[4] as int,
      mistIntervalDays: fields[5] as int,
      fertilizerIntervalDays: fields[6] as int,
      nextWaterDate: fields[7] as DateTime,
      nextMistDate: fields[8] as DateTime?,
      nextFertilizerDate: fields[9] as DateTime?,
      ownerEmail: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Plant obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.species)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.waterIntervalDays)
      ..writeByte(5)
      ..write(obj.mistIntervalDays)
      ..writeByte(6)
      ..write(obj.fertilizerIntervalDays)
      ..writeByte(7)
      ..write(obj.nextWaterDate)
      ..writeByte(8)
      ..write(obj.nextMistDate)
      ..writeByte(9)
      ..write(obj.nextFertilizerDate)
      ..writeByte(10)
      ..write(obj.ownerEmail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
