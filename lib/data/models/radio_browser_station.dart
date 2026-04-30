class RadioBrowserStation {
  final String stationUuid;
  final String name;
  final String? urlResolved;
  final String? url;
  final String? country;
  final String? countryCode;
  final String? state;
  final String? tags;
  final String? homepage;
  final int? bitrate;
  final String? codec;
  final int? lastCheckOk;

  const RadioBrowserStation({
    required this.stationUuid,
    required this.name,
    this.urlResolved,
    this.url,
    this.country,
    this.countryCode,
    this.state,
    this.tags,
    this.homepage,
    this.bitrate,
    this.codec,
    this.lastCheckOk,
  });

  String? get playableUrl {
    if (urlResolved != null && urlResolved!.trim().isNotEmpty) return urlResolved;
    if (url != null && url!.trim().isNotEmpty) return url;
    return null;
  }

  bool get isStreamHealthy => lastCheckOk == 1 && playableUrl != null;

  factory RadioBrowserStation.fromJson(Map<String, dynamic> json) {
    return RadioBrowserStation(
      stationUuid: json['stationuuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      urlResolved: json['url_resolved'] as String?,
      url: json['url'] as String?,
      country: json['country'] as String?,
      countryCode: json['countrycode'] as String?,
      state: json['state'] as String?,
      tags: json['tags'] as String?,
      homepage: json['homepage'] as String?,
      bitrate: (json['bitrate'] as num?)?.toInt(),
      codec: json['codec'] as String?,
      lastCheckOk: (json['lastcheckok'] as num?)?.toInt(),
    );
  }
}
