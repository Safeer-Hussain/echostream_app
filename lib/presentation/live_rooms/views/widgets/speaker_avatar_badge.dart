import 'package:flutter/material.dart';

import '../../../../domain/entities/live_room.dart';

class SpeakerAvatarBadge extends StatelessWidget {
  final LiveSpeaker speaker;

  const SpeakerAvatarBadge({super.key, required this.speaker});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Speaking Pulse Ring
            if (speaker.isSpeaking)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.95, end: 1.15),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Container(
                    width: 64.0 * scale,
                    height: 64.0 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.5),
                        width: 2.5,
                      ),
                    ),
                  );
                },
              ),
            Container(
              width: 58.0,
              height: 58.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: speaker.isSpeaking
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: speaker.isSpeaking ? 2.5 : 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  speaker.avatarAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.person_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            // Mute / Speaker Badge
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: speaker.isMuted
                      ? colorScheme.error
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 1.5),
                ),
                child: Icon(
                  speaker.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  size: 11.0,
                  color: speaker.isMuted
                      ? colorScheme.onError
                      : colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Text(
          speaker.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2.0),
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.0),
          decoration: BoxDecoration(
            color: speaker.role == 'Host'
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            speaker.role.toUpperCase(),
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: speaker.role == 'Host'
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
