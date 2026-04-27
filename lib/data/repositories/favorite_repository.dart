import '../datasources/hive_datasource.dart';
import '../models/favorite.dart';
import '../models/station.dart';

class FavoriteRepository {
  final HiveDatasource _datasource;

  FavoriteRepository({required HiveDatasource datasource})
      : _datasource = datasource;

  List<Favorite> getAll() => _datasource.getFavorites();

  Future<void> add(Station station) async {
    final favorite = Favorite(
      stationId: station.id,
      stationName: station.name,
      streamUrl: station.streamUrl,
      faviconUrl: station.faviconUrl,
      fmFrequency: station.fmFrequency,
      amFrequency: station.amFrequency,
    );
    await _datasource.addFavorite(favorite);
  }

  Future<void> remove(String stationId) async {
    await _datasource.removeFavorite(stationId);
  }

  bool isFavorite(String stationId) => _datasource.isFavorite(stationId);
}
