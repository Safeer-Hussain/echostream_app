import 'package:flutter/material.dart';

import '../../../../domain/entities/audio_track.dart';

class ChapterTimelineSheet extends StatelessWidget {
  final AudioTrack track;
  final int currentPositionSec;
  final ValueChanged<int> onSeek;

  const ChapterTimelineSheet({
    super.key,
    required this.track,
    required this.currentPositionSec,
    required this.onSeek,
  });

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Synchronized Chapters & Transcripts',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${track.chapters.length} Chapters',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'Tap any chapter segment to seek audio playback directly.',
                style: TextStyle(
                  fontSize: 12.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16.0),
              if (track.chapters.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      'No chapters defined for this stream.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ...track.chapters.map((chapter) {
                  final isActive =
                      currentPositionSec >= chapter.startTimeSec &&
                      currentPositionSec < chapter.endTimeSec;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primaryContainer.withOpacity(0.3)
                          : colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: isActive ? 1.5 : 1.0,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            _formatTime(chapter.startTimeSec),
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        title: Text(
                          chapter.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isActive
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            chapter.summary,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        trailing: Icon(
                          isActive
                              ? Icons.volume_up_rounded
                              : Icons.play_arrow_rounded,
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          size: 20.0,
                        ),
                        onTap: () {
                          onSeek(chapter.startTimeSec);
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Episode Transcript Excerpt',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      track.transcriptText,
                      style: TextStyle(
                        fontSize: 12.0,
                        height: 1.45,
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
    );
  }
}
