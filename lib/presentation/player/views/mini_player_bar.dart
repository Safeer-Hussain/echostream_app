import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_player_bloc.dart';
import 'spatial_player_deck_view.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        final track = state.currentTrack;
        if (track == null) return const SizedBox.shrink();

        final colorScheme = Theme.of(context).colorScheme;
        final progress = track.durationSec > 0
            ? (state.currentPositionSec / track.durationSec).clamp(0.0, 1.0)
            : 0.0;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SpatialPlayerDeckView()),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: colorScheme.outlineVariant, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.12),
                  blurRadius: 10.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            track.coverAsset,
                            width: 44.0,
                            height: 44.0,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              width: 44.0,
                              height: 44.0,
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.music_note_rounded,
                                color: colorScheme.primary,
                                size: 24.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                      vertical: 1.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      '24-BIT',
                                      style: TextStyle(
                                        fontSize: 9.0,
                                        fontWeight: FontWeight.w800,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6.0),
                                  Expanded(
                                    child: Text(
                                      track.artist,
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
                            ],
                          ),
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
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            state.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            color: colorScheme.primary,
                            size: 32.0,
                          ),
                          onPressed: () {
                            context.read<AudioPlayerBloc>().add(
                              TogglePlayPauseEvent(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 2.5,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
