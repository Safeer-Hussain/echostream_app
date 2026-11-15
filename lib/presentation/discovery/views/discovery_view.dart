import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/audio_track.dart';
import '../../player/bloc/audio_player_bloc.dart';
import '../bloc/discovery_bloc.dart';

class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _primaryScrollController = ScrollController();
  final ScrollController _secondaryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(LoadCatalogEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _primaryScrollController.dispose();
    _secondaryScrollController.dispose();
    super.dispose();
  }

  String _formatDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m}m ${s > 0 ? '${s}s' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<DiscoveryBloc, DiscoveryState>(
      builder: (context, state) {
        final tracks = state.tracks;

        if (isLandscape) {
          // Two-pane master-detail layout for 360dp landscape safe
          return Row(
            children: [
              // Left Pane: Search & Filter Chips
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  controller: _primaryScrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSearchField(context),
                      const SizedBox(height: 8.0),
                      Text(
                        'Acoustic Genres & Labs',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 6.0,
                        children: AppConstants.catalogGenres.map((genre) {
                          final isSelected = state.selectedGenre == genre;
                          return ChoiceChip(
                            label: Text(
                              genre,
                              style: TextStyle(
                                fontSize: 11.0,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: colorScheme.primary,
                            backgroundColor: colorScheme.surfaceContainer,
                            side: BorderSide(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                            ),
                            onSelected: (_) {
                              context.read<DiscoveryBloc>().add(
                                SelectGenreFilterEvent(genre),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12.0),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Catalog Index',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '${tracks.length} lossless engineering sessions indexed in SQLite.',
                              style: TextStyle(
                                fontSize: 11.0,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              VerticalDivider(width: 1.0, color: colorScheme.outlineVariant),
              // Right Pane: Tracks List
              Expanded(
                flex: 7,
                child: tracks.isEmpty
                    ? Center(
                        child: Text(
                          'No lossless sessions found.',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        controller: _secondaryScrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        itemCount: tracks.length,
                        itemBuilder: (context, index) {
                          return _buildTrackCard(context, tracks[index]);
                        },
                      ),
              ),
            ],
          );
        }

        // Portrait Layout
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: _buildSearchField(context),
            ),
            SizedBox(
              height: 38.0,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: AppConstants.catalogGenres.length,
                separatorBuilder: (context, i) => const SizedBox(width: 8.0),
                itemBuilder: (context, index) {
                  final genre = AppConstants.catalogGenres[index];
                  final isSelected = state.selectedGenre == genre;
                  return ChoiceChip(
                    label: Text(
                      genre,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: colorScheme.primary,
                    backgroundColor: colorScheme.surfaceContainer,
                    side: BorderSide(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                    onSelected: (_) {
                      context.read<DiscoveryBloc>().add(
                        SelectGenreFilterEvent(genre),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: tracks.isEmpty
                  ? Center(
                      child: Text(
                        'No lossless sessions found for "${state.selectedGenre}".',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      controller: _primaryScrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        return _buildTrackCard(context, tracks[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _searchController,
      style: TextStyle(fontSize: 13.5, color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Search 24+ engineering sessions, topics...',
        hintStyle: TextStyle(
          fontSize: 13.0,
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colorScheme.onSurfaceVariant,
          size: 20.0,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18.0),
                onPressed: () {
                  _searchController.clear();
                  context.read<DiscoveryBloc>().add(
                    const SearchCatalogEvent(''),
                  );
                },
              )
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 8.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      onChanged: (val) {
        context.read<DiscoveryBloc>().add(SearchCatalogEvent(val));
      },
    );
  }

  Widget _buildTrackCard(BuildContext context, AudioTrack track) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 6.0,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset(
              track.coverAsset,
              width: 52.0,
              height: 52.0,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                width: 52.0,
                height: 52.0,
                color: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.headset_rounded,
                  color: colorScheme.primary,
                  size: 26.0,
                ),
              ),
            ),
          ),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    track.sampleRate,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    '${track.artist} • ${_formatDuration(track.durationSec)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (track.isDownloaded)
                Icon(
                  Icons.download_done_rounded,
                  color: colorScheme.primary,
                  size: 18.0,
                ),
              IconButton(
                icon: Icon(
                  track.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: track.isLiked
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                  size: 20.0,
                ),
                onPressed: () {
                  context.read<AudioPlayerBloc>().add(
                    ToggleLikeCurrentTrackEvent(),
                  );
                  context.read<DiscoveryBloc>().add(LoadCatalogEvent());
                },
              ),
            ],
          ),
          onTap: () {
            context.read<AudioPlayerBloc>().add(LoadTrackEvent(track));
          },
        ),
      ),
    );
  }
}
