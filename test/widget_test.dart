import 'package:flutter_test/flutter_test.dart';
import 'package:echo_stream_app/presentation/adaptive_scaffold.dart';

import 'mocks/test_harness.dart';

void main() {
  setUp(() async {
    await initTestServiceLocator();
  });

  testWidgets('App root smoke test renders AdaptiveScaffold', (tester) async {
    await tester.pumpWidget(createTestWidget(child: const AdaptiveScaffold()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('EchoStream Discovery'), findsOneWidget);
  });
}
