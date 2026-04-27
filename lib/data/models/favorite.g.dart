// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteAdapter extends TypeAdapter<Favorite> {
  @override
  final int typeId = 1;

  @override
  Favorite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Favorite(
      stationId: fields[0] as String,
      stationName: fields[1] as String,
      streamUrl: fields[2] as String,
      faviconUrl: fields[3] as String?,
      fmFrequency: fields[4] as double?,
      amFrequency: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Favorite obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.stationId)
      ..writeByte(1)
      ..write(obj.stationName)
      ..writeByte(2)
      ..write(obj.streamUrl)
      ..writeByte(3)
      ..write(obj.faviconUrl)
      ..writeByte(4)
      ..write(obj.fmFrequency)
      ..writeByte(5)
      ..write(obj.amFrequency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
