import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echo_stream_app/core/network/mock_dio_interceptor.dart';
import 'package:echo_stream_app/core/services/service_locator.dart';
import 'package:echo_stream_app/core/theme/app_theme.dart';
import 'package:echo_stream_app/core/theme/theme_cubit.dart';
import 'package:echo_stream_app/domain/repositories/analytics_repository.dart';
import 'package:echo_stream_app/domain/repositories/audio_repository.dart';
import 'package:echo_stream_app/domain/repositories/dsp_repository.dart';
import 'package:echo_stream_app/domain/repositories/live_room_repository.dart';
import 'package:echo_stream_app/presentation/ai_copilot/ai_audio_copilot_cubit.dart';
import 'package:echo_stream_app/presentation/discovery/bloc/discovery_bloc.dart';
import 'package:echo_stream_app/presentation/equalizer/bloc/equalizer_bloc.dart';
import 'package:echo_stream_app/presentation/live_rooms/bloc/live_room_bloc.dart';
import 'package:echo_stream_app/presentation/player/bloc/audio_player_bloc.dart';
import 'package:echo_stream_app/presentation/vault/bloc/vault_bloc.dart';

import 'mock_repositories.dart';

Future<void> initTestServiceLocator({
  MockAudioRepository? audioRepo,
  MockDspRepository? dspRepo,
  MockLiveRoomRepository? liveRoomRepo,
  MockAnalyticsRepository? analyticsRepo,
}) async {
  SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
  final prefs = await SharedPreferences.getInstance();

  if (getIt.isRegistered<SharedPreferences>()) {
    getIt.unregister<SharedPreferences>();
  }
  getIt.registerSingleton<SharedPreferences>(prefs);

  if (getIt.isRegistered<MockDioInterceptor>()) {
    getIt.unregister<MockDioInterceptor>();
  }
  getIt.registerSingleton<MockDioInterceptor>(MockDioInterceptor());

  final mockAudioRepo = audioRepo ?? MockAudioRepository();
  if (getIt.isRegistered<AudioRepository>()) {
    getIt.unregister<AudioRepository>();
  }
  getIt.registerSingleton<AudioRepository>(mockAudioRepo);

  final mockDspRepo = dspRepo ?? MockDspRepository();
  if (getIt.isRegistered<DspRepository>()) {
    getIt.unregister<DspRepository>();
  }
  getIt.registerSingleton<DspRepository>(mockDspRepo);

  final mockLiveRoomRepo = liveRoomRepo ?? MockLiveRoomRepository();
  if (getIt.isRegistered<LiveRoomRepository>()) {
    getIt.unregister<LiveRoomRepository>();
  }
  getIt.registerSingleton<LiveRoomRepository>(mockLiveRoomRepo);

  final mockAnalyticsRepo = analyticsRepo ?? MockAnalyticsRepository();
  if (getIt.isRegistered<AnalyticsRepository>()) {
    getIt.unregister<AnalyticsRepository>();
  }
  getIt.registerSingleton<AnalyticsRepository>(mockAnalyticsRepo);
}

Widget createTestWidget({
  required Widget child,
  ThemeMode themeMode = ThemeMode.dark,
}) {
  final audioRepo = getIt<AudioRepository>();
  final dspRepo = getIt<DspRepository>();
  final liveRoomRepo = getIt<LiveRoomRepository>();
  final analyticsRepo = getIt<AnalyticsRepository>();
  final prefs = getIt<SharedPreferences>();

  return MultiBlocProvider(
    providers: [
      BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(prefs)),
      BlocProvider<AudioPlayerBloc>(
        create: (_) =>
            AudioPlayerBloc(audioRepository: audioRepo, dspRepository: dspRepo),
      ),
      BlocProvider<EqualizerBloc>(
        create: (_) => EqualizerBloc(dspRepository: dspRepo),
      ),
      BlocProvider<LiveRoomBloc>(
        create: (_) => LiveRoomBloc(liveRoomRepository: liveRoomRepo),
      ),
      BlocProvider<DiscoveryBloc>(
        create: (_) => DiscoveryBloc(audioRepository: audioRepo),
      ),
      BlocProvider<VaultBloc>(
        create: (_) => VaultBloc(audioRepository: audioRepo),
      ),
      BlocProvider<AiAudioCopilotCubit>(
        create: (_) => AiAudioCopilotCubit(
          audioRepository: audioRepo,
          analyticsRepository: analyticsRepo,
        ),
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: child,
    ),
  );
}
