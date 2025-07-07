// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'death_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeathEntityAdapter extends TypeAdapter<DeathEntity> {
  @override
  final int typeId = 2;

  @override
  DeathEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeathEntity(
      id: fields[0] as String,
      batchId: fields[1] as String,
      count: fields[2] as int,
      date: fields[3] as DateTime,
      userId: fields[4] as String,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DeathEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.batchId)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeathEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
