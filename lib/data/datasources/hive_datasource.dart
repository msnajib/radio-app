import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/frequencies.dart';
import '../models/favorite.dart';

class HiveDatasource {
  late Box<Favorite> _favoritesBox;
  late Box<dynamic> _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FavoriteAdapter());
    _favoritesBox = await Hive.openBox<Favorite>(AppConstants.favoritesBox);
    _settingsBox = await Hive.openBox<dynamic>(AppConstants.settingsBox);
  }

  // ── Dial state persistence ─────────────────────────────────────────────────

  double getDialPosition() =>
      (_settingsBox.get('dialPosition') as double?) ?? 0.0;

  Band getDialBand() {
    final s = _settingsBox.get('dialBand') as String?;
    return s == 'am' ? Band.am : Band.fm;
  }

  Future<void> saveDialPosition(double position) =>
      _settingsBox.put('dialPosition', position);

  Future<void> saveDialBand(Band band) =>
      _settingsBox.put('dialBand', band == Band.am ? 'am' : 'fm');

  List<Favorite> getFavorites() => _favoritesBox.values.toList();

  Future<void> addFavorite(Favorite favorite) async {
    await _favoritesBox.put(favorite.stationId, favorite);
  }

  Future<void> removeFavorite(String stationId) async {
    await _favoritesBox.delete(stationId);
  }

  bool isFavorite(String stationId) => _favoritesBox.containsKey(stationId);
}
