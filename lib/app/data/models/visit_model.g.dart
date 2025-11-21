// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VisitResponseModelAdapter extends TypeAdapter<VisitResponseModel> {
  @override
  final int typeId = 12;

  @override
  VisitResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VisitResponseModel(
      id: fields[0] as int,
      transType: fields[1] as int,
      customerVendorName: fields[2] as String,
      customerVendorId: fields[3] as int,
      date: fields[4] as DateTime,
      latitude: fields[5] as double,
      longitude: fields[6] as double,
      notes: fields[7] as String,
      agentId: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, VisitResponseModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transType)
      ..writeByte(2)
      ..write(obj.customerVendorName)
      ..writeByte(3)
      ..write(obj.customerVendorId)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.agentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
