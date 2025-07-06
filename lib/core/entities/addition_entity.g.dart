// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addition_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdditionEntityAdapter extends TypeAdapter<AdditionEntity> {
  @override
  final int typeId = 1;

  @override
  AdditionEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdditionEntity(
      id: fields[0] as String,
      batchId: fields[1] as String,
      name: fields[2] as String,
      cost: fields[3] as double,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AdditionEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.batchId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.cost)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
