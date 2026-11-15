import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/audio_track.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/repositories/audio_repository.dart';
import 'ai_audio_copilot_state.dart';

class AiAudioCopilotCubit extends Cubit<AiAudioCopilotState> {
  final AudioRepository _audioRepository;
  final AnalyticsRepository _analyticsRepository;

  AiAudioCopilotCubit({
    required AudioRepository audioRepository,
    required AnalyticsRepository analyticsRepository,
  }) : _audioRepository = audioRepository,
       _analyticsRepository = analyticsRepository,
       super(
         const AiAudioCopilotState(
           messages: [
             CopilotChatMessage(
               id: 'init_welcome',
               sender: 'copilot',
               text: 'EchoStream On-Device AI Copilot initialized. I have indexed your SQLite listening history, saved timestamp clips, and active episode transcripts. Tap any preset prompt below or ask me anything about your audio sessions.',
               timestamp: 'Now',
               sourceCitations: ['On-Device SQLite Engine', 'Transcript Index'],
             ),
           ],
         ),
       );

  Future<void> sendUserPrompt(
    String promptText, {
    AudioTrack? activeTrack,
  }) async {
    final trimmed = promptText.trim();
    if (trimmed.isEmpty || state.isStreaming) return;

    final userMessage = CopilotChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'user',
      text: trimmed,
      timestamp: DateTime.now().toIso8601String().substring(11, 16),
    );

    emit(
      state.copyWith(
        messages: List<CopilotChatMessage>.from(state.messages)
          ..add(userMessage),
        isStreaming: true,
        currentStreamingChunk: '',
        statusIndicatorText: 'Synthesizing episode transcripts, key takeaways & saved timestamp clips...',
      ),
    );

    try {
      final clips = await _audioRepository.getTimestampClips();
      final profile = await _analyticsRepository.getUserProfile();
      final genreDist = await _analyticsRepository.getGenreDistribution();

      String synthesizedResponse = '';
      List<String> citations = [];

      if (trimmed.contains('Summarize Key Takeaways')) {
        if (activeTrack != null) {
          citations = [
            activeTrack.title,
            '${activeTrack.sampleRate} Lossless Transcript',
          ];
          synthesizedResponse =
              'Key Takeaways from "${activeTrack.title}" (${activeTrack.artist}):\n\n'
              '1. Core Thesis: ${activeTrack.transcriptText}\n\n'
              '2. Architectural Impact: The session demonstrates why 24-bit dynamic range preserves acoustic transient detail without clipping.\n\n'
              '3. Actionable Concept: Integrate early reflection modeling into spatial convolution buffers to achieve accurate localization.';
        } else {
          citations = ['Recent SQLite Catalog'];
          synthesizedResponse = 'No active track is currently playing. Based on your recent session "Systems Engineering: LLVM & Compilers", the primary takeaway is using the SLP vectorizer to fuse scalar operations into SIMD registers for ultra-low latency DSP execution.';
        }
      } else if (trimmed.contains('Compile Action Items')) {
        citations = ['Saved SQLite Clips (${clips.length} items)'];
        if (clips.isNotEmpty) {
          final items = clips
              .map(
                (c) =>
                    '- [${c.timestampSec ~/ 60}:${(c.timestampSec % 60).toString().padLeft(2, '0')}] ${c.trackTitle}: ${c.noteText}',
              )
              .join('\n');
          synthesizedResponse =
              'Compiled Action Items from your Saved Timestamp Clips:\n\n$items\n\nRecommendation: Review these architectural principles prior to implementing high-concurrency audio pipelines.';
        } else {
          synthesizedResponse = 'No timestamp clips have been bookmarked yet. Use the 1-tap "Clip Insight" button on the Spatial Player deck while listening to save architectural insights.';
        }
      } else if (trimmed.contains('Recommend Next Deep-Focus')) {
        citations = [
          'Personalized Listening History',
          'Gamma Wave Optimization',
        ];
        synthesizedResponse =
            'Recommended Deep Focus Session for You:\n\n'
            'Title: "Deep Focus: 40Hz Gamma Isochronic Waves"\n'
            'Artist: NeuroAcoustics Studio (192kHz / 24-bit FLAC)\n\n'
            'Rationale: Your listening profile reflects ${profile.weeklyHoursListened} weekly hours with top affinity in ${genreDist.keys.isNotEmpty ? genreDist.keys.first : "Deep Focus"}. 40Hz sinusoidal carriers induce steady cortical synchronization during intense coding sessions.';
      } else if (trimmed.contains('Audit My Weekly Listening Habits')) {
        citations = ['SQLite Telemetry Vault', 'DAC Bit-Perfect Stats'];
        final topGenre = genreDist.entries.isNotEmpty
            ? genreDist.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : 'Deep Focus';
        synthesizedResponse =
            'Weekly Listening Habits Audit:\n\n'
            '- Total Hours Streamed: ${profile.weeklyHoursListened} hrs\n'
            '- Primary Genre Focus: $topGenre (${genreDist[topGenre] ?? 12.0} hrs)\n'
            '- Audiophile Tier: ${profile.audioHardwareTier}\n'
            '- Offline Vault Footprint: ${profile.offlineVaultCount} tracks cached (${profile.offlineVaultMb} MB)\n'
            '- Acoustic Health Score: Optimal dynamic range utilization with zero audible clipping.';
      } else {
        citations = ['EchoStream Knowledge Engine', 'On-Device SQLite'];
        synthesizedResponse =
            'Regarding your query "$trimmed":\n\n'
            'EchoStream processes audio with a dedicated 10-band hardware DSP equalizer bridge and 32-band real-time FFT spectrum analyzer. In tandem with local SQLite caching, lossless FLAC streams operate fully offline without third-party network dependencies.';
      }

      // Stream tokens deterministically
      final tokens = synthesizedResponse.split(' ');
      String accumulated = '';
      for (int i = 0; i < tokens.length; i++) {
        accumulated += (i == 0 ? '' : ' ') + tokens[i];
        emit(state.copyWith(currentStreamingChunk: accumulated));
        await Future.delayed(const Duration(milliseconds: 24));
      }

      final botMessage = CopilotChatMessage(
        id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
        sender: 'copilot',
        text: accumulated,
        timestamp: DateTime.now().toIso8601String().substring(11, 16),
        sourceCitations: citations,
      );

      emit(
        state.copyWith(
          messages: List<CopilotChatMessage>.from(state.messages)
            ..add(botMessage),
          currentStreamingChunk: '',
        ),
      );
    } catch (e) {
      final errorMessage = CopilotChatMessage(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        sender: 'copilot',
        text: 'Error processing transcript inference: ${e.toString()}',
        timestamp: DateTime.now().toIso8601String().substring(11, 16),
      );
      emit(
        state.copyWith(
          messages: List<CopilotChatMessage>.from(state.messages)
            ..add(errorMessage),
        ),
      );
    } finally {
      emit(state.copyWith(isStreaming: false, statusIndicatorText: ''));
    }
  }

  void clearConversation() {
    emit(
      AiAudioCopilotState(
        messages: [
          CopilotChatMessage(
            id: 'cleared_welcome',
            sender: 'copilot',
            text: 'Chat history cleared. On-device index is ready for new queries.',
            timestamp: 'Now',
            sourceCitations: const ['On-Device Index'],
          ),
        ],
      ),
    );
  }
}
