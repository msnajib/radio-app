// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StationAdapter extends TypeAdapter<Station> {
  @override
  final int typeId = 0;

  @override
  Station read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Station(
      id: fields[0] as String,
      name: fields[1] as String,
      streamUrl: fields[2] as String,
      codec: fields[3] as String?,
      bitrate: fields[4] as int,
      faviconUrl: fields[5] as String?,
      tags: (fields[6] as List).cast<String>(),
      country: fields[7] as String?,
      fmFrequency: fields[8] as double?,
      amFrequency: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Station obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.streamUrl)
      ..writeByte(3)
      ..write(obj.codec)
      ..writeByte(4)
      ..write(obj.bitrate)
      ..writeByte(5)
      ..write(obj.faviconUrl)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.country)
      ..writeByte(8)
      ..write(obj.fmFrequency)
      ..writeByte(9)
      ..write(obj.amFrequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
