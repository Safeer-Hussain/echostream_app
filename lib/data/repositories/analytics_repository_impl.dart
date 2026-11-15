import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/database/app_database.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AppDatabase _appDatabase;

  AnalyticsRepositoryImpl(this._appDatabase);

  @override
  Future<UserProfile> getUserProfile() async {
    final db = await _appDatabase.database;
    final downloadedMaps = await db.query('tracks', where: 'isDownloaded = 1');
    final count = downloadedMaps.length;
    double totalSizeMb = 0.0;
    for (final map in downloadedMaps) {
      totalSizeMb += (map['fileSizeMb'] as num).toDouble();
    }

    final totalHistory = await db.rawQuery(
      'SELECT SUM(listenedSec) as totalSec FROM listening_history',
    );
    final totalSec =
        (totalHistory.first['totalSec'] as num?)?.toDouble() ?? 32400.0;
    final totalHours = totalSec / 3600.0;

    return UserProfile(
      name: 'Safeer Hussain',
      handle: '@safeer_hussain',
      email: 'safeer@echostream.studio',
      avatarAsset: 'assets/images/avatar_host_2.png',
      audioHardwareTier: 'Audiophile Reference 192kHz DAC',
      weeklyHoursListened: double.parse(totalHours.toStringAsFixed(1)),
      totalTracksCompleted: 48,
      offlineVaultCount: count,
      offlineVaultMb: double.parse(totalSizeMb.toStringAsFixed(1)),
    );
  }

  @override
  Future<Map<String, double>> getWeeklyListeningHours() async {
    final db = await _appDatabase.database;
    final maps = await db.rawQuery('''
      SELECT dayOfWeek, SUM(listenedSec) as totalSec 
      FROM listening_history 
      GROUP BY dayOfWeek
    ''');

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final result = <String, double>{};
    for (final day in days) {
      result[day] = 0.0;
    }

    for (final m in maps) {
      final day = m['dayOfWeek'] as String?;
      final sec = (m['totalSec'] as num?)?.toDouble() ?? 0.0;
      if (day != null && result.containsKey(day)) {
        result[day] = double.parse((sec / 3600.0).toStringAsFixed(1));
      }
    }

    // Default realistic curve if zero
    if (result.values.every((v) => v == 0.0)) {
      result['Mon'] = 2.4;
      result['Tue'] = 3.6;
      result['Wed'] = 4.2;
      result['Thu'] = 2.8;
      result['Fri'] = 3.9;
      result['Sat'] = 5.4;
      result['Sun'] = 4.8;
    }

    return result;
  }

  @override
  Future<Map<String, double>> getGenreDistribution() async {
    final db = await _appDatabase.database;
    final maps = await db.rawQuery('''
      SELECT genre, SUM(listenedSec) as totalSec 
      FROM listening_history 
      GROUP BY genre
    ''');

    final result = <String, double>{};
    for (final m in maps) {
      final genre = m['genre'] as String;
      final sec = (m['totalSec'] as num?)?.toDouble() ?? 0.0;
      result[genre] = double.parse((sec / 3600.0).toStringAsFixed(1));
    }

    if (result.isEmpty) {
      result['Deep Focus'] = 14.5;
      result['Systems & AI'] = 12.0;
      result['Lossless Master'] = 6.4;
      result['Acoustic'] = 5.2;
      result['Tech Keynotes'] = 4.8;
    }

    return result;
  }

  @override
  Future<void> recordListeningSession(
    String trackId,
    int seconds,
    String genre,
  ) async {
    final db = await _appDatabase.database;
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayOfWeek = dayNames[DateTime.now().weekday - 1];

    await db.insert('listening_history', {
      'trackId': trackId,
      'listenedSec': seconds,
      'genre': genre,
      'dayOfWeek': dayOfWeek,
    });
  }
}
