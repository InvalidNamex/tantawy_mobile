// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerTransactionModelAdapter
    extends TypeAdapter<CustomerTransactionModel> {
  @override
  final int typeId = 20;

  @override
  CustomerTransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerTransactionModel(
      customerId: fields[0] as int,
      customerName: fields[1] as String,
      transactions: (fields[2] as List).cast<TransactionModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, CustomerTransactionModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.customerId)
      ..writeByte(1)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.transactions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerTransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 21;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      createdAt: fields[0] as DateTime,
      amount: fields[1] as double,
      notes: fields[2] as String,
      type: fields[3] as int,
      invoiceId: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.createdAt)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.invoiceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
