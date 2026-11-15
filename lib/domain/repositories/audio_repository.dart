import '../entities/audio_track.dart';
import '../entities/playlist.dart';
import '../entities/timestamp_clip.dart';

abstract class AudioRepository {
  Future<List<AudioTrack>> getTracks({String? genreQuery, String? searchQuery});
  Future<AudioTrack?> getTrackById(String id);
  Future<void> toggleLikeTrack(String trackId);
  Future<void> setDownloadStatus(String trackId, bool isDownloaded);
  Future<void> updatePlaybackProgress(String trackId, int positionSec);

  // Playlists
  Future<List<Playlist>> getPlaylists();
  Future<void> createPlaylist(String title, String description);
  Future<void> addTrackToPlaylist(String playlistId, String trackId);
  Future<void> removeTrackFromPlaylist(String playlistId, String trackId);

  // Timestamp Clips
  Future<List<TimestampClip>> getTimestampClips({String? trackId});
  Future<void> saveTimestampClip(TimestampClip clip);
  Future<void> deleteTimestampClip(String clipId);

  // Vault Management
  Future<List<AudioTrack>> getDownloadedTracks();
  Future<void> purgeOfflineCache();
}
