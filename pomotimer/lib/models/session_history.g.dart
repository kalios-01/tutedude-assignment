// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionHistoryAdapter extends TypeAdapter<SessionHistory> {
  @override
  final int typeId = 0;

  @override
  SessionHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionHistory(
      date: fields[0] as String,
      sessions: (fields[1] as List).cast<int>(),
      totalDuration: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SessionHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.sessions)
      ..writeByte(2)
      ..write(obj.totalDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
