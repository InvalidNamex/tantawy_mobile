// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_balance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CashBalanceModelAdapter extends TypeAdapter<CashBalanceModel> {
  @override
  final int typeId = 14;

  @override
  CashBalanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CashBalanceModel(
      agentId: fields[0] as int,
      agentName: fields[1] as String,
      agentUsername: fields[2] as String,
      totalDebit: fields[3] as double,
      totalCredit: fields[4] as double,
      balance: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CashBalanceModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.agentId)
      ..writeByte(1)
      ..write(obj.agentName)
      ..writeByte(2)
      ..write(obj.agentUsername)
      ..writeByte(3)
      ..write(obj.totalDebit)
      ..writeByte(4)
      ..write(obj.totalCredit)
      ..writeByte(5)
      ..write(obj.balance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashBalanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
