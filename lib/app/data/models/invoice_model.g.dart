// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceResponseModelAdapter extends TypeAdapter<InvoiceResponseModel> {
  @override
  final int typeId = 10;

  @override
  InvoiceResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceResponseModel(
      id: fields[0] as int,
      invoiceType: fields[1] as int,
      invoiceNumber: fields[2] as String?,
      customerVendorName: fields[3] as String,
      customerVendorId: fields[4] as int,
      netTotal: fields[5] as double,
      totalPaid: fields[6] as double,
      status: fields[7] as int,
      paymentType: fields[8] as int,
      invoiceDate: fields[9] as DateTime,
      storeId: fields[10] as int,
      agentId: fields[11] as int,
      storeName: fields[12] as String?,
      discountAmount: fields[13] as double,
      taxAmount: fields[14] as double,
      notes: fields[15] as String?,
      invoiceDetails: (fields[16] as List?)?.cast<InvoiceDetailResponse>(),
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceResponseModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceType)
      ..writeByte(2)
      ..write(obj.invoiceNumber)
      ..writeByte(3)
      ..write(obj.customerVendorName)
      ..writeByte(4)
      ..write(obj.customerVendorId)
      ..writeByte(5)
      ..write(obj.netTotal)
      ..writeByte(6)
      ..write(obj.totalPaid)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.paymentType)
      ..writeByte(9)
      ..write(obj.invoiceDate)
      ..writeByte(10)
      ..write(obj.storeId)
      ..writeByte(11)
      ..write(obj.agentId)
      ..writeByte(12)
      ..write(obj.storeName)
      ..writeByte(13)
      ..write(obj.discountAmount)
      ..writeByte(14)
      ..write(obj.taxAmount)
      ..writeByte(15)
      ..write(obj.notes)
      ..writeByte(16)
      ..write(obj.invoiceDetails);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvoiceDetailResponseAdapter extends TypeAdapter<InvoiceDetailResponse> {
  @override
  final int typeId = 15;

  @override
  InvoiceDetailResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceDetailResponse(
      itemID: fields[0] as int,
      itemName: fields[1] as String,
      itemQuantity: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceDetailResponse obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.itemID)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.itemQuantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceDetailResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
