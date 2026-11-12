// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_usage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUsageAdapter extends TypeAdapter<AppUsage> {
  @override
  final int typeId = 2;

  @override
  AppUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUsage(
      icon: fields,
      appCategory: '',
      durationMinutes: '',
      timeByHour: <String, int>{},
      id: fields[0] as String,
      childId: fields[1] as String,
      appPackageName: fields[2] as String,
      appName: fields[3] as String,
      date: fields[4] as DateTime,
      minutesUsed: fields[5] as int,
      launchCount: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AppUsage obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.childId)
      ..writeByte(2)
      ..write(obj.appPackageName)
      ..writeByte(3)
      ..write(obj.appName)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.minutesUsed)
      ..writeByte(6)
      ..write(obj.launchCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
