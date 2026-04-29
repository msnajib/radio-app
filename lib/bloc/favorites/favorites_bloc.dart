import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/analytics_service.dart';
import '../../data/repositories/favorite_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoriteRepository _repository;
  final AnalyticsService _analytics;

  FavoritesBloc({
    required FavoriteRepository repository,
    required AnalyticsService analytics,
  })  : _repository = repository,
        _analytics = analytics,
        super(const FavoritesState()) {
    on<FavoritesLoaded>(_onLoaded);
    on<FavoriteAdded>(_onAdded);
    on<FavoriteRemoved>(_onRemoved);
  }

  void _onLoaded(FavoritesLoaded event, Emitter<FavoritesState> emit) {
    emit(state.copyWith(favorites: _repository.getAll()));
  }

  Future<void> _onAdded(
    FavoriteAdded event,
    Emitter<FavoritesState> emit,
  ) async {
    await _repository.add(event.station);
    _analytics.logStationFavorite(event.station, added: true);
    emit(state.copyWith(favorites: _repository.getAll()));
  }

  Future<void> _onRemoved(
    FavoriteRemoved event,
    Emitter<FavoritesState> emit,
  ) async {
    final favorite = state.favorites.where((f) => f.stationId == event.stationId).firstOrNull;
    await _repository.remove(event.stationId);
    if (favorite != null) _analytics.logStationFavoriteRemoved(favorite);
    emit(state.copyWith(favorites: _repository.getAll()));
  }
}
