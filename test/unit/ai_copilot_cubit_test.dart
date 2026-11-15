import 'package:flutter_test/flutter_test.dart';
import 'package:echo_stream_app/presentation/ai_copilot/ai_audio_copilot_cubit.dart';

import '../mocks/mock_repositories.dart';

void main() {
  late MockAudioRepository mockAudioRepo;
  late MockAnalyticsRepository mockAnalyticsRepo;
  late AiAudioCopilotCubit aiCopilotCubit;

  setUp(() {
    mockAudioRepo = MockAudioRepository();
    mockAnalyticsRepo = MockAnalyticsRepository();
    aiCopilotCubit = AiAudioCopilotCubit(
      audioRepository: mockAudioRepo,
      analyticsRepository: mockAnalyticsRepo,
    );
  });

  tearDown(() {
    aiCopilotCubit.close();
  });

  group('AiAudioCopilotCubit Unit Tests', () {
    test(
      '12. Initial state contains welcome message and isStreaming is false',
      () {
        expect(aiCopilotCubit.state.isStreaming, false);
        expect(aiCopilotCubit.state.messages.length, 1);
        expect(aiCopilotCubit.state.messages.first.sender, 'copilot');
      },
    );

    test('13. sendUserPrompt streams tokens and guarantees isStreaming=false in finally', () async {
      final track = mockAudioRepo.tracks.first;
      final future = aiCopilotCubit.sendUserPrompt(
        'Summarize Key Takeaways From Current Episode',
        activeTrack: track,
      );

      // Verify that after future completes, isStreaming is guaranteed false
      await future;
      expect(aiCopilotCubit.state.isStreaming, false);
      expect(aiCopilotCubit.state.statusIndicatorText, '');
      expect(aiCopilotCubit.state.messages.length >= 3, true);
      expect(aiCopilotCubit.state.messages.last.sender, 'copilot');
    });

    test(
      '14. clearConversation clears history and leaves ready welcome prompt',
      () {
        aiCopilotCubit.clearConversation();
        expect(aiCopilotCubit.state.messages.length, 1);
        expect(aiCopilotCubit.state.messages.first.id, 'cleared_welcome');
        expect(aiCopilotCubit.state.isStreaming, false);
      },
    );
  });
}
