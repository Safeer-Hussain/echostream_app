import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/mock_dio_interceptor.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/utils/app_feedback.dart';
import '../../live_rooms/bloc/live_room_bloc.dart';

class RecruiterDebugDrawer extends StatefulWidget {
  const RecruiterDebugDrawer({super.key});

  @override
  State<RecruiterDebugDrawer> createState() => _RecruiterDebugDrawerState();
}

class _RecruiterDebugDrawerState extends State<RecruiterDebugDrawer> {
  late MockDioInterceptor _interceptor;
  bool _force503 = false;
  bool _simulateOffline = false;
  int _latencyMs = 600;

  @override
  void initState() {
    super.initState();
    _interceptor = getIt<MockDioInterceptor>();
    _force503 = _interceptor.forceHttp503Error;
    _simulateOffline = _interceptor.simulateOffline;
    _latencyMs = (_interceptor.minLatencyMs + _interceptor.maxLatencyMs) ~/ 2;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.terminal_rounded,
                    color: colorScheme.primary,
                    size: 24.0,
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    'Recruiter Debug Drawer',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              Text(
                'Live architectural diagnostics & fault simulation controls.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16.0),
              // Simulated Latency Slider
              Text(
                'Simulated Dio Network Latency: ${_latencyMs}ms',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Slider(
                value: _latencyMs.toDouble(),
                min: 100.0,
                max: 2000.0,
                divisions: 19,
                activeColor: colorScheme.primary,
                onChanged: (val) {
                  setState(() {
                    _latencyMs = val.toInt();
                    _interceptor.minLatencyMs = (_latencyMs * 0.7).toInt();
                    _interceptor.maxLatencyMs = (_latencyMs * 1.3).toInt();
                  });
                },
              ),
              const Divider(),
              // Force HTTP 503 Fault
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Force HTTP 503 Service Unavailable',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Simulates server capacity degradation for retry logic test',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _force503,
                activeColor: colorScheme.error,
                onChanged: (val) {
                  setState(() {
                    _force503 = val;
                    _interceptor.forceHttp503Error = val;
                  });
                  AppFeedback.showWarning(
                    context,
                    val
                        ? 'Simulated HTTP 503 active on network requests.'
                        : 'HTTP 503 simulation disabled.',
                  );
                },
              ),
              const Divider(),
              // Simulate Offline Network
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Simulate Full Network Offline Mode',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Tests SQLite Vault local fallback resilience',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _simulateOffline,
                activeColor: colorScheme.primary,
                onChanged: (val) {
                  setState(() {
                    _simulateOffline = val;
                    _interceptor.simulateOffline = val;
                  });
                  AppFeedback.showInfo(
                    context,
                    val
                        ? 'Offline Vault Mode active: Playing cached local tracks.'
                        : 'Online connectivity restored.',
                  );
                },
              ),
              const Divider(),
              // Inject Live Speaker Invite
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.record_voice_over_rounded,
                  color: colorScheme.primary,
                ),
                title: Text(
                  'Inject Live Stage Speaker Invite',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Dynamically promotes participant into active Live Room',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  context.read<LiveRoomBloc>().add(
                    const PromoteParticipantEvent(
                      'room_01',
                      'Recruiter Guest Architect',
                    ),
                  );
                  AppFeedback.showSuccess(
                    context,
                    'Injected "Recruiter Guest Architect" onto Live Stage!',
                  );
                  Navigator.of(context).pop();
                },
              ),
              const Divider(),
              // Architecture Telemetry Info
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Runtime Telemetry',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      '• Flutter: 3.47+ / Dart 3.13+\n'
                      '• Architecture: Feature-First Clean MVVM/BLoC\n'
                      '• Database: sqflite + SharedPreferences\n'
                      '• DSP Bridge: Method & Event Channels\n'
                      '• Zero Emojis / Zero Deprecation Errors',
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.4,
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
