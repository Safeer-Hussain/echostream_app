import 'dart:io';

Future<void> main() async {
  stdout.writeln('==================================================');
  stdout.writeln('EchoStream Autonomous Sprint Gate Verification');
  stdout.writeln('==================================================\n');

  final isWindows = Platform.isWindows;
  final flutterCmd = isWindows ? 'flutter.bat' : 'flutter';
  final dartCmd = isWindows ? 'dart.bat' : 'dart';

  stdout.writeln('Running: Anti-AI Code Hygiene (Zero Emojis)');
  final emojiRegex = RegExp(
    r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}]',
    unicode: true,
  );
  int emojiCount = 0;
  for (final dirName in ['lib', 'test', 'docs', 'tool']) {
    final dir = Directory(dirName);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File &&
          (entity.path.endsWith('.dart') || entity.path.endsWith('.md'))) {
        final content = entity.readAsStringSync();
        if (emojiRegex.hasMatch(content)) {
          stderr.writeln('FAIL: Emoji detected in ${entity.path}');
          emojiCount++;
        }
      }
    }
  }
  if (emojiCount > 0) {
    stderr.writeln('FAILURE: Anti-AI Hygiene violated ($emojiCount files contain emojis).');
    exit(1);
  }
  stdout.writeln('SUCCESS: Zero emojis found across codebase.\n');

  final steps = <_GateStep>[
    _GateStep(
      name: 'Dependencies Check',
      executable: flutterCmd,
      arguments: ['pub', 'get'],
    ),
    _GateStep(
      name: 'Dart Code Formatting',
      executable: dartCmd,
      arguments: ['format', 'lib', 'test'],
    ),
    _GateStep(
      name: 'Flutter Static Analysis',
      executable: flutterCmd,
      arguments: ['analyze', '--no-fatal-infos', '--no-pub'],
    ),
    _GateStep(
      name: 'Automated Test Suite',
      executable: flutterCmd,
      arguments: ['test', '--no-pub'],
    ),
  ];

  for (final step in steps) {
    stdout.writeln('Running: ${step.name} [${step.executable} ${step.arguments.join(" ")}]');
    final stopwatch = Stopwatch()..start();

    final result = await Process.run(
      step.executable,
      step.arguments,
      runInShell: true,
    );

    stopwatch.stop();

    if (result.stdout.toString().trim().isNotEmpty) {
      stdout.writeln(result.stdout.toString().trim());
    }
    if (result.stderr.toString().trim().isNotEmpty) {
      stderr.writeln(result.stderr.toString().trim());
    }

    if (result.exitCode != 0) {
      stderr.writeln(
        '\nFAILED: ${step.name} exited with status code ${result.exitCode} (${stopwatch.elapsedMilliseconds}ms)',
      );
      exit(result.exitCode);
    }

    stdout.writeln(
      'SUCCESS: ${step.name} completed in ${stopwatch.elapsedMilliseconds}ms\n',
    );
  }

  stdout.writeln('==================================================');
  stdout.writeln('All EchoStream Sprint Gate checks PASSED cleanly!');
  stdout.writeln('==================================================');
}

class _GateStep {
  final String name;
  final String executable;
  final List<String> arguments;

  const _GateStep({
    required this.name,
    required this.executable,
    required this.arguments,
  });
}
