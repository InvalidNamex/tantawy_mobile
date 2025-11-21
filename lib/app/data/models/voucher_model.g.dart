// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoucherResponseModelAdapter extends TypeAdapter<VoucherResponseModel> {
  @override
  final int typeId = 11;

  @override
  VoucherResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VoucherResponseModel(
      id: fields[0] as int,
      type: fields[1] as int,
      voucherNumber: fields[2] as String?,
      customerVendorName: fields[3] as String,
      customerVendorId: fields[4] as int,
      amount: fields[5] as double,
      notes: fields[6] as String,
      voucherDate: fields[7] as DateTime,
      storeId: fields[8] as int,
      agentId: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, VoucherResponseModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.voucherNumber)
      ..writeByte(3)
      ..write(obj.customerVendorName)
      ..writeByte(4)
      ..write(obj.customerVendorId)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.voucherDate)
      ..writeByte(8)
      ..write(obj.storeId)
      ..writeByte(9)
      ..write(obj.agentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoucherResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
