import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/favorite_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoriteRepository _repository;

  FavoritesBloc({required FavoriteRepository repository})
      : _repository = repository,
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
    emit(state.copyWith(favorites: _repository.getAll()));
  }

  Future<void> _onRemoved(
    FavoriteRemoved event,
    Emitter<FavoritesState> emit,
  ) async {
    await _repository.remove(event.stationId);
    emit(state.copyWith(favorites: _repository.getAll()));
  }
}
