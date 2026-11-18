import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../../../domain/entities/audio_track.dart';
import '../bloc/audio_player_bloc.dart';
import 'widgets/chapter_timeline_sheet.dart';
import 'widgets/fft_spectrum_painter.dart';
import 'widgets/share_timestamp_sheet.dart';

class SpatialPlayerDeckView extends StatefulWidget {
  const SpatialPlayerDeckView({super.key});

  @override
  State<SpatialPlayerDeckView> createState() => _SpatialPlayerDeckViewState();
}

class _SpatialPlayerDeckViewState extends State<SpatialPlayerDeckView> {
  final ScrollController _leftScrollController = ScrollController();
  final ScrollController _rightScrollController = ScrollController();

  @override
  void dispose() {
    _leftScrollController.dispose();
    _rightScrollController.dispose();
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showClipDialog(
    BuildContext context,
    AudioPlayerBloc bloc,
    int timestampSec,
  ) {
    final controller = TextEditingController();
    final timeStr = _formatTime(timestampSec);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(dialogCtx).colorScheme.surfaceContainer,
        title: Text(
          'Clip Timestamp Insight at $timeStr',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            color: Theme.of(dialogCtx).colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a personal engineering takeaway or note for this timestamp:',
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(dialogCtx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(
                color: Theme.of(dialogCtx).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., Vectorized loop invariant code motion',
                hintStyle: TextStyle(
                  color: Theme.of(dialogCtx).colorScheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Theme.of(dialogCtx).colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(dialogCtx).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              final note = controller.text.trim();
              bloc.add(
                SaveTimestampClipEvent(
                  note.isEmpty ? 'Insight bookmark' : note,
                ),
              );
              Navigator.of(dialogCtx).pop();
              AppFeedback.showSuccess(
                context,
                'Saved timestamp insight at $timeStr to SQLite.',
              );
            },
            child: const Text('Save Clip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        final track = state.currentTrack;
        if (track == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Spatial Player Deck')),
            body: const Center(child: Text('No active audio stream loaded.')),
          );
        }

        final activeChapter = state.activeChapter;
        final currentPos = state.currentPositionSec;
        final duration = track.durationSec > 0 ? track.durationSec : 1;

        if (isLandscape) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              toolbarHeight: 36.0,
              title: Text(
                track.title,
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 18.0),
                  onPressed: () => _openShareSheet(context, track, currentPos),
                ),
              ],
            ),
            body: SafeArea(
              child: Row(
                children: [
                  // Left Pane: Cover & Visualizer
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      controller: _leftScrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.asset(
                              track.coverAsset,
                              height: 140.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          SizedBox(
                            height: 70.0,
                            child: CustomPaint(
                              painter: FftSpectrumPainter(
                                bands: state.spectrum.bands,
                                primaryColor: colorScheme.primary,
                                secondaryColor: colorScheme.secondary,
                                backgroundColor: colorScheme.surfaceContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Center(
                            child: Text(
                              '${state.spectrum.sampleRate} • DR${state.spectrum.dynamicRangeScore.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 1.0,
                    color: colorScheme.outlineVariant,
                  ),
                  // Right Pane: Title, Scrubber, Controls
                  Expanded(
                    flex: 7,
                    child: SingleChildScrollView(
                      controller: _rightScrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            track.artist,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          _buildScrubber(context, state, currentPos, duration),
                          const SizedBox(height: 6.0),
                          _buildPlaybackControls(
                            context,
                            state,
                            track,
                            currentPos,
                          ),
                          const SizedBox(height: 8.0),
                          _buildChapterBar(
                            context,
                            track,
                            activeChapter,
                            currentPos,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Portrait Layout
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28.0),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLAYING FROM CATALOG',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  track.album,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _openShareSheet(context, track, currentPos),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_clip_timestamp',
            onPressed: () {
              _showClipDialog(
                context,
                context.read<AudioPlayerBloc>(),
                currentPos,
              );
            },
            icon: const Icon(Icons.bookmark_add_outlined, size: 18.0),
            label: Text('Clip ${_formatTime(currentPos)}'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8.0),
                  Center(
                    child: Container(
                      width: 250.0,
                      height: 250.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.18),
                            blurRadius: 28.0,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.asset(track.coverAsset, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Real-time 32-band FFT Spectrum Visualizer
                  SizedBox(
                    height: 72.0,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: FftSpectrumPainter(
                        bands: state.spectrum.bands,
                        primaryColor: colorScheme.primary,
                        secondaryColor: colorScheme.secondary,
                        backgroundColor: colorScheme.surfaceContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3.0,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          state.spectrum.sampleRate,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'DR${state.spectrum.dynamicRangeScore.toStringAsFixed(1)} • Latency ${state.spectrum.bufferLatencyMs}ms',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Track Title & Artist & Favorite
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: colorScheme.onSurfaceVariant,
                              ),
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
                          size: 26.0,
                        ),
                        onPressed: () {
                          context.read<AudioPlayerBloc>().add(
                            ToggleLikeCurrentTrackEvent(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  _buildScrubber(context, state, currentPos, duration),
                  const SizedBox(height: 8.0),
                  _buildPlaybackControls(context, state, track, currentPos),
                  const SizedBox(height: 16.0),
                  _buildChapterBar(context, track, activeChapter, currentPos),
                  const SizedBox(height: 80.0), // Padding for extended FAB
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrubber(
    BuildContext context,
    AudioPlayerState state,
    int currentPos,
    int duration,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
            activeTrackColor: state.loopMode == LoopMode.abRepeat
                ? colorScheme.secondary
                : colorScheme.primary,
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
            thumbColor: state.loopMode == LoopMode.abRepeat
                ? colorScheme.secondary
                : colorScheme.primary,
          ),
          child: Slider(
            value: currentPos.toDouble().clamp(0.0, duration.toDouble()),
            min: 0.0,
            max: duration.toDouble(),
            onChanged: (val) {
              context.read<AudioPlayerBloc>().add(
                SeekPositionEvent(val.toInt()),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(currentPos),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (state.loopMode == LoopMode.abRepeat && state.isAbLoopValid)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 1.0,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    'Loop ${_formatTime(state.abLoopStartSec!)} - ${_formatTime(state.abLoopEndSec!)}',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              Text(
                _formatTime(duration),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (state.loopMode == LoopMode.abRepeat)
          _buildAbLoopControlBar(context, state, currentPos),
      ],
    );
  }

  Widget _buildAbLoopControlBar(
    BuildContext context,
    AudioPlayerState state,
    int currentPos,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<AudioPlayerBloc>();

    final start = state.abLoopStartSec;
    final end = state.abLoopEndSec;

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: state.isAbLoopValid
                ? colorScheme.secondary.withOpacity(0.5)
                : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.all_inclusive_rounded,
                  size: 14.0,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 6.0),
                Text(
                  start != null ? 'A: ${_formatTime(start)}' : 'A: Not set',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  end != null ? 'B: ${_formatTime(end)}' : 'B: Not set',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => bloc.add(SetAbLoopPointAEvent(currentPos)),
                  borderRadius: BorderRadius.circular(4.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    child: Text(
                      'Set A',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
                InkWell(
                  onTap: () => bloc.add(SetAbLoopPointBEvent(currentPos)),
                  borderRadius: BorderRadius.circular(4.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 2.0,
                    ),
                    child: Text(
                      'Set B',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                if (start != null || end != null) ...[
                  const SizedBox(width: 4.0),
                  InkWell(
                    onTap: () => bloc.add(ClearAbLoopEvent()),
                    borderRadius: BorderRadius.circular(4.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14.0,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackControls(
    BuildContext context,
    AudioPlayerState state,
    AudioTrack track,
    int currentPos,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<AudioPlayerBloc>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Playback Speed Selector
        TextButton(
          onPressed: () {
            final nextSpeed = state.playbackSpeed == 1.0
                ? 1.25
                : state.playbackSpeed == 1.25
                ? 1.5
                : state.playbackSpeed == 1.5
                ? 2.0
                : 1.0;
            bloc.add(SetPlaybackSpeedEvent(nextSpeed));
          },
          child: Text(
            '${state.playbackSpeed}x',
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.replay_10_rounded, size: 28.0),
          color: colorScheme.onSurface,
          onPressed: () => bloc.add(const SkipBackwardEvent(seconds: 15)),
        ),
        IconButton(
          iconSize: 56.0,
          color: colorScheme.primary,
          icon: Icon(
            state.isPlaying
                ? Icons.pause_circle_filled_rounded
                : Icons.play_circle_filled_rounded,
          ),
          onPressed: () => bloc.add(TogglePlayPauseEvent()),
        ),
        IconButton(
          icon: const Icon(Icons.forward_30_rounded, size: 28.0),
          color: colorScheme.onSurface,
          onPressed: () => bloc.add(const SkipForwardEvent(seconds: 30)),
        ),
        // Loop Mode Selector (Off -> Track -> A-B)
        IconButton(
          icon: Icon(
            state.loopMode == LoopMode.off
                ? Icons.repeat_rounded
                : state.loopMode == LoopMode.track
                ? Icons.repeat_one_rounded
                : Icons.repeat_on_rounded,
            size: 24.0,
          ),
          color: state.loopMode == LoopMode.off
              ? colorScheme.onSurfaceVariant
              : colorScheme.primary,
          tooltip: state.loopMode == LoopMode.off
              ? 'Loop: Off'
              : state.loopMode == LoopMode.track
              ? 'Loop: Track'
              : 'Loop: A-B Range',
          onPressed: () => bloc.add(CycleLoopModeEvent()),
        ),
        IconButton(
          icon: const Icon(Icons.queue_music_rounded, size: 24.0),
          color: colorScheme.onSurfaceVariant,
          onPressed: () {
            _openChaptersSheet(context, track, currentPos, (sec) {
              bloc.add(SeekPositionEvent(sec));
            });
          },
        ),
      ],
    );
  }

  Widget _buildChapterBar(
    BuildContext context,
    AudioTrack track,
    dynamic activeChapter,
    int currentPos,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<AudioPlayerBloc>();

    return InkWell(
      onTap: () {
        _openChaptersSheet(context, track, currentPos, (sec) {
          bloc.add(SeekPositionEvent(sec));
        });
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.segment_rounded, color: colorScheme.primary, size: 20.0),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVE CHAPTER',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    activeChapter != null
                        ? activeChapter.title
                        : 'Tap to view chapters & transcript',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  void _openChaptersSheet(
    BuildContext context,
    AudioTrack track,
    int currentPos,
    ValueChanged<int> onSeek,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (_) => ChapterTimelineSheet(
        track: track,
        currentPositionSec: currentPos,
        onSeek: onSeek,
      ),
    );
  }

  void _openShareSheet(BuildContext context, AudioTrack track, int currentPos) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (_) =>
          ShareTimestampSheet(track: track, currentPositionSec: currentPos),
    );
  }
}
