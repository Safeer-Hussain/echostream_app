import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/audio_track.dart';
import '../../../domain/repositories/audio_repository.dart';

// Events
abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();
  @override
  List<Object?> get props => [];
}

class LoadCatalogEvent extends DiscoveryEvent {}

class SelectGenreFilterEvent extends DiscoveryEvent {
  final String genre;
  const SelectGenreFilterEvent(this.genre);
  @override
  List<Object?> get props => [genre];
}

class SearchCatalogEvent extends DiscoveryEvent {
  final String query;
  const SearchCatalogEvent(this.query);
  @override
  List<Object?> get props => [query];
}

// State
class DiscoveryState extends Equatable {
  final List<AudioTrack> tracks;
  final String selectedGenre;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const DiscoveryState({
    this.tracks = const [],
    this.selectedGenre = 'All',
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  DiscoveryState copyWith({
    List<AudioTrack>? tracks,
    String? selectedGenre,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DiscoveryState(
      tracks: tracks ?? this.tracks,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    tracks,
    selectedGenre,
    searchQuery,
    isLoading,
    errorMessage,
  ];
}

// BLoC
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final AudioRepository _audioRepository;

  DiscoveryBloc({required AudioRepository audioRepository})
    : _audioRepository = audioRepository,
      super(const DiscoveryState()) {
    on<LoadCatalogEvent>(_onLoadCatalog);
    on<SelectGenreFilterEvent>(_onSelectGenreFilter);
    on<SearchCatalogEvent>(_onSearchCatalog);
  }

  Future<void> _onLoadCatalog(
    LoadCatalogEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final tracks = await _audioRepository.getTracks(
        genreQuery: state.selectedGenre,
        searchQuery: state.searchQuery,
      );
      emit(state.copyWith(tracks: tracks, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSelectGenreFilter(
    SelectGenreFilterEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(state.copyWith(selectedGenre: event.genre, isLoading: true));
    final tracks = await _audioRepository.getTracks(
      genreQuery: event.genre,
      searchQuery: state.searchQuery,
    );
    emit(state.copyWith(tracks: tracks, isLoading: false));
  }

  Future<void> _onSearchCatalog(
    SearchCatalogEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query, isLoading: true));
    final tracks = await _audioRepository.getTracks(
      genreQuery: state.selectedGenre,
      searchQuery: event.query,
    );
    emit(state.copyWith(tracks: tracks, isLoading: false));
  }
}
