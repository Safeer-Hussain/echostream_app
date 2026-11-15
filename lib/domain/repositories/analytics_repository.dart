import '../entities/user_profile.dart';

abstract class AnalyticsRepository {
  Future<UserProfile> getUserProfile();
  Future<Map<String, double>> getWeeklyListeningHours();
  Future<Map<String, double>> getGenreDistribution();
  Future<void> recordListeningSession(
    String trackId,
    int seconds,
    String genre,
  );
}
