import 'station.dart';

enum SignalStrength { strong, weak, none }

class MatchResult {
  final Station localStation;
  final Station? apiStation;
  final int score;
  final SignalStrength strength;
  final String source; // 'manual' | 'auto' | 'none'

  const MatchResult({
    required this.localStation,
    required this.apiStation,
    required this.score,
    required this.strength,
    required this.source,
  });

  bool get hasStream => apiStation != null && apiStation!.streamUrl.isNotEmpty;

  // Merges local station identity with API station stream URL.
  Station get playableStation => localStation.copyWith(
        streamUrl: apiStation?.streamUrl ?? '',
      );
}
