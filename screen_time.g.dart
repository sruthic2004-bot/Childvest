// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_time.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScreenTimeAdapter extends TypeAdapter<ScreenTime> {
  @override
  final int typeId = 11;

  @override
  ScreenTime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScreenTime(
      id: fields[0] as String,
      childId: fields[1] as String,
      date: fields[2] as DateTime,
      totalMinutes: fields[3] as int,
      timeByHour: (fields[4] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScreenTime obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.childId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.totalMinutes)
      ..writeByte(4)
      ..write(obj.timeByHour);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenTimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
