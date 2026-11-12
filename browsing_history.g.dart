// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browsing_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BrowsingHistoryAdapter extends TypeAdapter<BrowsingHistory> {
  @override
  final int typeId = 3;

  @override
  BrowsingHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BrowsingHistory(
      id: fields[0] as String,
      childId: fields[1] as String,
      url: fields[2] as String,
      title: fields[3] as String,
      timestamp: fields[4] as DateTime,
      timeSpentSeconds: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, BrowsingHistory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.childId)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.timeSpentSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowsingHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
