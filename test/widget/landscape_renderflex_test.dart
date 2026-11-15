import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echo_stream_app/presentation/adaptive_scaffold.dart';

import '../mocks/test_harness.dart';

void main() {
  setUp(() async {
    await initTestServiceLocator();
  });

  group('Landscape RenderFlex Safety Tests (800x360)', () {
    testWidgets(
      '17. 800x360 landscape switches to compact NavigationRail with zero overflows',
      (tester) async {
        tester.view.physicalSize = const Size(800, 360);
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

        // NavigationRail is rendered
        expect(find.byType(NavigationRail), findsOneWidget);
        // BottomNavigationBar is NOT rendered
        expect(find.byType(BottomNavigationBar), findsNothing);

        // Verify no RenderFlex overflow exceptions occurred
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '18. Equalizer and Live Stage render cleanly without RenderFlex overflows in landscape',
      (tester) async {
        tester.view.physicalSize = const Size(800, 360);
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

        expect(tester.takeException(), isNull, reason: 'Initial load failed');

        // Tap Equalizer rail destination
        await tester.tap(find.byIcon(Icons.equalizer_outlined));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('DSP Equalizer Presets'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Equalizer tab failed');

        // Tap Live Stage rail destination
        await tester.tap(find.byIcon(Icons.podcasts_outlined));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('Host Live Room'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Live stage failed');
      },
    );
  });
}
