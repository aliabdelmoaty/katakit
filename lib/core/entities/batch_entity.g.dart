// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BatchEntityAdapter extends TypeAdapter<BatchEntity> {
  @override
  final int typeId = 0;

  @override
  BatchEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BatchEntity(
      id: fields[0] as String,
      name: fields[1] as String,
      date: fields[2] as DateTime,
      supplier: fields[3] as String,
      chickCount: fields[4] as int,
      chickBuyPrice: fields[5] as double,
      note: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BatchEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.supplier)
      ..writeByte(4)
      ..write(obj.chickCount)
      ..writeByte(5)
      ..write(obj.chickBuyPrice)
      ..writeByte(7)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
