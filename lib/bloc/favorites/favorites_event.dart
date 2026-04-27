import 'package:equatable/equatable.dart';
import '../../data/models/station.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

class FavoritesLoaded extends FavoritesEvent {
  const FavoritesLoaded();
}

class FavoriteAdded extends FavoritesEvent {
  final Station station;
  const FavoriteAdded(this.station);
  @override
  List<Object?> get props => [station];
}

class FavoriteRemoved extends FavoritesEvent {
  final String stationId;
  const FavoriteRemoved(this.stationId);
  @override
  List<Object?> get props => [stationId];
}
