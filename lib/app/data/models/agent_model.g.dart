// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AgentModelAdapter extends TypeAdapter<AgentModel> {
  @override
  final int typeId = 0;

  @override
  AgentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AgentModel(
      id: fields[0] as int,
      name: fields[1] as String,
      token: fields[2] as String,
      storeID: fields[3] as int,
      username: fields[4] == null ? '' : fields[4] as String,
      password: fields[5] == null ? '' : fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AgentModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.token)
      ..writeByte(3)
      ..write(obj.storeID)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
