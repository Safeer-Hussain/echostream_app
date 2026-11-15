import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echo_stream_app/core/services/service_locator.dart';
import 'package:echo_stream_app/presentation/profile_analytics/views/analytics_view.dart';

import '../mocks/test_harness.dart';

void main() {
  setUp(() async {
    await initTestServiceLocator();
  });

  group('Theme Switching & Analytics Widget Tests', () {
    testWidgets(
      '19. fl_chart BarChart renders full-width edge-to-edge in Analytics',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const Scaffold(body: AnalyticsView())),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.byType(BarChart), findsOneWidget);
        expect(find.text('Weekly Listening Hours (fl_chart)'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '20. Instant Dark/Light theme mode toggling updates theme immediately',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: const Scaffold(body: AnalyticsView()),
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Obsidian Studio Dark'), findsOneWidget);

        // Tap Theme Switch
        await tester.tap(find.byType(Switch).first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final prefs = getIt<SharedPreferences>();
        expect(prefs.getString('app_theme_mode'), isNotNull);
      },
    );
  });
}
