import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/database/app_database.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../data/repositories/dsp_repository_impl.dart';
import '../../data/repositories/live_room_repository_impl.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../domain/repositories/dsp_repository.dart';
import '../../domain/repositories/live_room_repository.dart';
import '../network/mock_dio_interceptor.dart';
import 'audio_dsp_bridge.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator({SharedPreferences? preferences}) async {
  final prefs = preferences ?? await SharedPreferences.getInstance();
  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(prefs);
  }

  // Network & Mock Dio
  if (!getIt.isRegistered<MockDioInterceptor>()) {
    final interceptor = MockDioInterceptor();
    getIt.registerSingleton<MockDioInterceptor>(interceptor);

    final dio = Dio();
    dio.interceptors.add(interceptor);
    getIt.registerSingleton<Dio>(dio);
  }

  // App Database (SQLite)
  if (!getIt.isRegistered<AppDatabase>()) {
    final database = AppDatabase();
    getIt.registerSingleton<AppDatabase>(database);
  }

  // Native DSP Bridge
  if (!getIt.isRegistered<AudioDspBridge>()) {
    final dspBridge = AudioDspBridge();
    getIt.registerSingleton<AudioDspBridge>(dspBridge);
  }

  // Repositories
  if (!getIt.isRegistered<AudioRepository>()) {
    getIt.registerLazySingleton<AudioRepository>(
      () => AudioRepositoryImpl(getIt<AppDatabase>()),
    );
  }

  if (!getIt.isRegistered<LiveRoomRepository>()) {
    getIt.registerLazySingleton<LiveRoomRepository>(
      () => LiveRoomRepositoryImpl(getIt<AppDatabase>()),
    );
  }

  if (!getIt.isRegistered<DspRepository>()) {
    getIt.registerLazySingleton<DspRepository>(
      () => DspRepositoryImpl(getIt<AppDatabase>(), getIt<AudioDspBridge>()),
    );
  }

  if (!getIt.isRegistered<AnalyticsRepository>()) {
    getIt.registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepositoryImpl(getIt<AppDatabase>()),
    );
  }
}
