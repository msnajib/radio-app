import 'package:hive/hive.dart';

part 'favorite.g.dart';

@HiveType(typeId: 1)
class Favorite extends HiveObject {
  @HiveField(0)
  final String stationId;

  @HiveField(1)
  final String stationName;

  @HiveField(2)
  final String streamUrl;

  @HiveField(3)
  final String? faviconUrl;

  @HiveField(4)
  final double? fmFrequency;

  @HiveField(5)
  final int? amFrequency;

  Favorite({
    required this.stationId,
    required this.stationName,
    required this.streamUrl,
    this.faviconUrl,
    this.fmFrequency,
    this.amFrequency,
  });
}
