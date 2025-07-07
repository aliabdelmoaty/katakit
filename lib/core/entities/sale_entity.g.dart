// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleEntityAdapter extends TypeAdapter<SaleEntity> {
  @override
  final int typeId = 3;

  @override
  SaleEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleEntity(
      id: fields[0] as String,
      batchId: fields[1] as String,
      buyerName: fields[2] as String,
      date: fields[3] as DateTime,
      chickCount: fields[4] as int,
      pricePerChick: fields[5] as double,
      paidAmount: fields[6] as double,
      note: fields[7] as String?,
      userId: fields[8] as String,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SaleEntity obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.batchId)
      ..writeByte(2)
      ..write(obj.buyerName)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.chickCount)
      ..writeByte(5)
      ..write(obj.pricePerChick)
      ..writeByte(6)
      ..write(obj.paidAmount)
      ..writeByte(7)
      ..write(obj.note)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
