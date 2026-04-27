import 'package:equatable/equatable.dart';
import '../../data/models/favorite.dart';

class FavoritesState extends Equatable {
  final List<Favorite> favorites;

  const FavoritesState({this.favorites = const []});

  bool isFavorite(String stationId) =>
      favorites.any((f) => f.stationId == stationId);

  FavoritesState copyWith({List<Favorite>? favorites}) {
    return FavoritesState(favorites: favorites ?? this.favorites);
  }

  @override
  List<Object?> get props => [favorites];
}
