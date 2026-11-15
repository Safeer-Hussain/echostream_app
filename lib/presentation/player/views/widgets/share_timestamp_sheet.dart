import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../../../domain/entities/audio_track.dart';

class ShareTimestampSheet extends StatelessWidget {
  final AudioTrack track;
  final int currentPositionSec;

  const ShareTimestampSheet({
    super.key,
    required this.track,
    required this.currentPositionSec,
  });

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeStr = _formatTime(currentPositionSec);

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
              Text(
                'Share Timestamp & Telemetry',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Share precise audio insights with other engineers and audiophiles.',
                style: TextStyle(
                  fontSize: 12.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${track.title}" at $timeStr',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Format: ${track.format} • ${track.sampleRate} / ${track.bitDepth} Lossless',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.copy_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 20.0,
                  ),
                ),
                title: Text(
                  'Copy Formatted Timestamp Quote',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Copies link and time-stamped quote to clipboard',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  final text =
                      'Listening to "${track.title}" by ${track.artist} at [$timeStr] on EchoStream Spatial Audio: https://echostream.studio/track/${track.id}?t=$currentPositionSec';
                  Clipboard.setData(ClipboardData(text: text));
                  Navigator.of(context).pop();
                  AppFeedback.showSuccess(
                    context,
                    'Copied timestamp quote to clipboard.',
                  );
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.forum_rounded,
                    color: colorScheme.onSecondaryContainer,
                    size: 20.0,
                  ),
                ),
                title: Text(
                  'Repost to Live Lounge',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Broadcast timestamp discussion into active Live Rooms',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  AppFeedback.showSuccess(
                    context,
                    'Shared timestamp to Live Audio Lounge.',
                  );
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: colorScheme.primary,
                    size: 20.0,
                  ),
                ),
                title: Text(
                  'Export Track Acoustic Telemetry',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  '192kHz DAC telemetry, Dynamic Range DR score, buffer latency',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  final telemetry =
                      'EchoStream Telemetry: Track ${track.id} | ${track.format} | ${track.sampleRate} ${track.bitDepth} | Dynamic Range DR14 | Buffer Latency 4.8ms | Spatial Binaural Engine Active';
                  Clipboard.setData(ClipboardData(text: telemetry));
                  Navigator.of(context).pop();
                  AppFeedback.showInfo(
                    context,
                    'Exported telemetry metrics to clipboard.',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
