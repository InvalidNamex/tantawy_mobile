// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_list_detail_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PriceListDetailModelAdapter extends TypeAdapter<PriceListDetailModel> {
  @override
  final int typeId = 4;

  @override
  PriceListDetailModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceListDetailModel(
      id: fields[0] as int,
      item: fields[1] as ItemInfo,
      priceList: fields[2] as PriceListInfoDetail,
      price: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PriceListDetailModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.item)
      ..writeByte(2)
      ..write(obj.priceList)
      ..writeByte(3)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceListDetailModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemInfoAdapter extends TypeAdapter<ItemInfo> {
  @override
  final int typeId = 5;

  @override
  ItemInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemInfo(
      id: fields[0] as int,
      itemName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemInfo obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PriceListInfoDetailAdapter extends TypeAdapter<PriceListInfoDetail> {
  @override
  final int typeId = 6;

  @override
  PriceListInfoDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceListInfoDetail(
      id: fields[0] as int,
      priceListName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PriceListInfoDetail obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.priceListName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceListInfoDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
