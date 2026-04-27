import 'package:hive/hive.dart';

part 'station.g.dart';

@HiveType(typeId: 0)
class Station extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String streamUrl;

  @HiveField(3)
  final String? codec;

  @HiveField(4)
  final int bitrate;

  @HiveField(5)
  final String? faviconUrl;

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  final String? country;

  // Real frequency (FM MHz or AM kHz). Null = no real frequency assigned.
  @HiveField(8)
  final double? fmFrequency;

  @HiveField(9)
  final int? amFrequency;

  Station({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.codec,
    this.bitrate = 0,
    this.faviconUrl,
    this.tags = const [],
    this.country,
    this.fmFrequency,
    this.amFrequency,
  });

  bool get hasFMFrequency => fmFrequency != null;
  bool get hasAMFrequency => amFrequency != null;

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['stationuuid'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      streamUrl: json['url_resolved'] as String? ?? json['url'] as String? ?? '',
      codec: json['codec'] as String?,
      bitrate: (json['bitrate'] as num?)?.toInt() ?? 0,
      faviconUrl: json['favicon'] as String?,
      tags: (json['tags'] as String? ?? '').split(',').where((t) => t.isNotEmpty).toList(),
      country: json['country'] as String?,
    );
  }

  Station copyWith({double? fmFrequency, int? amFrequency}) {
    return Station(
      id: id,
      name: name,
      streamUrl: streamUrl,
      codec: codec,
      bitrate: bitrate,
      faviconUrl: faviconUrl,
      tags: tags,
      country: country,
      fmFrequency: fmFrequency ?? this.fmFrequency,
      amFrequency: amFrequency ?? this.amFrequency,
    );
  }
}
