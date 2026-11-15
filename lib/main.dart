import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'domain/repositories/analytics_repository.dart';
import 'domain/repositories/audio_repository.dart';
import 'domain/repositories/dsp_repository.dart';
import 'domain/repositories/live_room_repository.dart';
import 'presentation/ai_copilot/ai_audio_copilot_cubit.dart';
import 'presentation/discovery/bloc/discovery_bloc.dart';
import 'presentation/equalizer/bloc/equalizer_bloc.dart';
import 'presentation/live_rooms/bloc/live_room_bloc.dart';
import 'presentation/player/bloc/audio_player_bloc.dart';
import 'presentation/splash/splash_view.dart';
import 'presentation/vault/bloc/vault_bloc.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
      };

      SharedPreferences? prefs;
      try {
        prefs = await SharedPreferences.getInstance();
        await setupServiceLocator(preferences: prefs);
      } catch (_) {
        // Defensive fallback if early services hit an issue
      }

      runApp(EchoStreamApp(preferences: prefs));
    },
    (error, stackTrace) {
      // Unhandled exception zone guard
    },
  );
}

class EchoStreamApp extends StatelessWidget {
  final SharedPreferences? preferences;

  const EchoStreamApp({super.key, this.preferences});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(preferences ?? getIt<SharedPreferences>()),
        ),
        BlocProvider<AudioPlayerBloc>(
          create: (_) => AudioPlayerBloc(
            audioRepository: getIt<AudioRepository>(),
            dspRepository: getIt<DspRepository>(),
          ),
        ),
        BlocProvider<EqualizerBloc>(
          create: (_) => EqualizerBloc(dspRepository: getIt<DspRepository>()),
        ),
        BlocProvider<LiveRoomBloc>(
          create: (_) =>
              LiveRoomBloc(liveRoomRepository: getIt<LiveRoomRepository>()),
        ),
        BlocProvider<DiscoveryBloc>(
          create: (_) =>
              DiscoveryBloc(audioRepository: getIt<AudioRepository>()),
        ),
        BlocProvider<VaultBloc>(
          create: (_) => VaultBloc(audioRepository: getIt<AudioRepository>()),
        ),
        BlocProvider<AiAudioCopilotCubit>(
          create: (_) => AiAudioCopilotCubit(
            audioRepository: getIt<AudioRepository>(),
            analyticsRepository: getIt<AnalyticsRepository>(),
          ),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          // Keyboard dismiss on tap outside (Rule 4)
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: MaterialApp(
              title: 'EchoStream',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const SplashView(),
            ),
          );
        },
      ),
    );
  }
}
