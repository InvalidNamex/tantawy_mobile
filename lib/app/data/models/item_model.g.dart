// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemModelAdapter extends TypeAdapter<ItemModel> {
  @override
  final int typeId = 3;

  @override
  ItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemModel(
      id: fields[0] as int,
      itemName: fields[1] as String,
      itemGroupId: fields[2] as int?,
      barcode: fields[3] as String,
      sign: fields[4] as String,
      mainUnitName: fields[5] as String?,
      subUnitName: fields[6] as String?,
      smallUnitName: fields[7] as String?,
      mainUnitPack: fields[8] as double?,
      subUnitPack: fields[9] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ItemModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.itemGroupId)
      ..writeByte(3)
      ..write(obj.barcode)
      ..writeByte(4)
      ..write(obj.sign)
      ..writeByte(5)
      ..write(obj.mainUnitName)
      ..writeByte(6)
      ..write(obj.subUnitName)
      ..writeByte(7)
      ..write(obj.smallUnitName)
      ..writeByte(8)
      ..write(obj.mainUnitPack)
      ..writeByte(9)
      ..write(obj.subUnitPack);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
