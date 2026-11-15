import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo_stream_app/presentation/adaptive_scaffold.dart';

import '../mocks/test_harness.dart';

void main() {
  setUp(() async {
    await initTestServiceLocator();
  });

  group('Hero Tag Safety Tests', () {
    testWidgets(
      '15. Zero duplicate Hero tag exceptions across multi-tab navigation',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          createTestWidget(child: const AdaptiveScaffold()),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.byType(BottomNavigationBar), findsOneWidget);

        // Navigate to Live Rooms tab (index 1) - has fab_host_live_room
        await tester.tap(find.text('Live Rooms'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(FloatingActionButton), findsOneWidget);
        final fab1 = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab1.heroTag, 'fab_host_live_room');

        // Navigate to Equalizer tab (index 2) - has fab_eq_save_preset
        await tester.tap(find.text('Equalizer'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(FloatingActionButton), findsOneWidget);
        final fab2 = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab2.heroTag, 'fab_eq_save_preset');

        // Navigate to Vault tab (index 3) - has fab_create_playlist
        await tester.tap(find.text('Vault'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(FloatingActionButton), findsOneWidget);
        final fab3 = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab3.heroTag, 'fab_create_playlist');

        // Navigate to Copilot tab (index 4) - has fab_ai_transcript_clear
        await tester.tap(find.text('Copilot'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(FloatingActionButton), findsOneWidget);
        final fab4 = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab4.heroTag, 'fab_ai_transcript_clear');
      },
    );

    testWidgets(
      '16. Discovery and Analytics tabs render without Hero tag collisions',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          createTestWidget(child: const AdaptiveScaffold()),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Discovery tab
        expect(find.text('EchoStream Discovery'), findsOneWidget);

        // Tap Analytics icon in AppBar
        await tester.tap(find.byIcon(Icons.analytics_outlined));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Listening Analytics & Hardware'), findsOneWidget);
      },
    );
  });
}
