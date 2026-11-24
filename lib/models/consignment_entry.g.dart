// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consignment_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConsignmentEntryAdapter extends TypeAdapter<ConsignmentEntry> {
  @override
  final int typeId = 2;

  @override
  ConsignmentEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConsignmentEntry(
      productName: fields[0] as String,
      price: fields[1] as double,
      quantity: fields[2] as int,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ConsignmentEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.productName)
      ..writeByte(1)
      ..write(obj.price)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsignmentEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
