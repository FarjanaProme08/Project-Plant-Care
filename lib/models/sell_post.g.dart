// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sell_post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SellPostAdapter extends TypeAdapter<SellPost> {
  @override
  final int typeId = 3;

  @override
  SellPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SellPost(
      id: fields[0] as String,
      sellerName: fields[1] as String,
      plantName: fields[2] as String,
      description: fields[3] as String,
      price: fields[4] as double,
      imagePath: fields[5] as String?,
      datePosted: fields[6] as DateTime,
      sellerEmail: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SellPost obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sellerName)
      ..writeByte(2)
      ..write(obj.plantName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.datePosted)
      ..writeByte(7)
      ..write(obj.sellerEmail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
