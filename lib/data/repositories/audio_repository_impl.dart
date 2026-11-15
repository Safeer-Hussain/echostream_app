import 'package:sqflite/sqflite.dart';

import '../../domain/entities/audio_track.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/timestamp_clip.dart';
import '../../domain/entities/transcript_chapter.dart';
import '../../domain/repositories/audio_repository.dart';
import '../datasources/database/app_database.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AppDatabase _appDatabase;

  AudioRepositoryImpl(this._appDatabase);

  @override
  Future<List<AudioTrack>> getTracks({
    String? genreQuery,
    String? searchQuery,
  }) async {
    final db = await _appDatabase.database;

    String whereClause = '';
    final whereArgs = <dynamic>[];

    if (genreQuery != null && genreQuery.isNotEmpty && genreQuery != 'All') {
      whereClause += 'genre = ?';
      whereArgs.add(genreQuery);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += '(title LIKE ? OR artist LIKE ? OR album LIKE ?)';
      final queryParam = '%${searchQuery.trim()}%';
      whereArgs.addAll([queryParam, queryParam, queryParam]);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'tracks',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'id ASC',
    );

    final tracks = <AudioTrack>[];
    for (final map in maps) {
      final trackId = map['id'] as String;
      final chapterMaps = await db.query(
        'chapters',
        where: 'trackId = ?',
        whereArgs: [trackId],
        orderBy: 'startTimeSec ASC',
      );
      final chapters = chapterMaps
          .map((c) => TranscriptChapter.fromMap(c))
          .toList();
      tracks.add(AudioTrack.fromMap(map, chapters));
    }
    return tracks;
  }

  @override
  Future<AudioTrack?> getTrackById(String id) async {
    final db = await _appDatabase.database;
    final maps = await db.query('tracks', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;

    final chapterMaps = await db.query(
      'chapters',
      where: 'trackId = ?',
      whereArgs: [id],
      orderBy: 'startTimeSec ASC',
    );
    final chapters = chapterMaps
        .map((c) => TranscriptChapter.fromMap(c))
        .toList();
    return AudioTrack.fromMap(maps.first, chapters);
  }

  @override
  Future<void> toggleLikeTrack(String trackId) async {
    final db = await _appDatabase.database;
    final track = await getTrackById(trackId);
    if (track == null) return;

    final newLiked = track.isLiked ? 0 : 1;
    await db.update(
      'tracks',
      {'isLiked': newLiked},
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  @override
  Future<void> setDownloadStatus(String trackId, bool isDownloaded) async {
    final db = await _appDatabase.database;
    await db.update(
      'tracks',
      {'isDownloaded': isDownloaded ? 1 : 0, 'isCached': 1},
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  @override
  Future<void> updatePlaybackProgress(String trackId, int positionSec) async {
    final db = await _appDatabase.database;
    await db.update(
      'tracks',
      {'playbackProgressSec': positionSec},
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    final db = await _appDatabase.database;
    final maps = await db.query('playlists', orderBy: 'createdAt DESC');
    return maps.map((m) => Playlist.fromMap(m)).toList();
  }

  @override
  Future<void> createPlaylist(String title, String description) async {
    final db = await _appDatabase.database;
    final newPlaylist = Playlist(
      id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      trackIds: const [],
      createdAt: DateTime.now().toIso8601String().split('T').first,
    );
    await db.insert('playlists', newPlaylist.toMap());
  }

  @override
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [playlistId],
    );
    if (maps.isEmpty) return;

    final playlist = Playlist.fromMap(maps.first);
    if (!playlist.trackIds.contains(trackId)) {
      final updatedTracks = List<String>.from(playlist.trackIds)..add(trackId);
      final updatedPlaylist = playlist.copyWith(trackIds: updatedTracks);
      await db.update(
        'playlists',
        updatedPlaylist.toMap(),
        where: 'id = ?',
        whereArgs: [playlistId],
      );
    }
  }

  @override
  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [playlistId],
    );
    if (maps.isEmpty) return;

    final playlist = Playlist.fromMap(maps.first);
    final updatedTracks = List<String>.from(playlist.trackIds)..remove(trackId);
    final updatedPlaylist = playlist.copyWith(trackIds: updatedTracks);
    await db.update(
      'playlists',
      updatedPlaylist.toMap(),
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  @override
  Future<List<TimestampClip>> getTimestampClips({String? trackId}) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      'timestamp_clips',
      where: trackId != null ? 'trackId = ?' : null,
      whereArgs: trackId != null ? [trackId] : null,
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => TimestampClip.fromMap(m)).toList();
  }

  @override
  Future<void> saveTimestampClip(TimestampClip clip) async {
    final db = await _appDatabase.database;
    await db.insert(
      'timestamp_clips',
      clip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteTimestampClip(String clipId) async {
    final db = await _appDatabase.database;
    await db.delete('timestamp_clips', where: 'id = ?', whereArgs: [clipId]);
  }

  @override
  Future<List<AudioTrack>> getDownloadedTracks() async {
    final db = await _appDatabase.database;
    final maps = await db.query('tracks', where: 'isDownloaded = 1');
    final tracks = <AudioTrack>[];
    for (final map in maps) {
      final trackId = map['id'] as String;
      final chapterMaps = await db.query(
        'chapters',
        where: 'trackId = ?',
        whereArgs: [trackId],
      );
      final chapters = chapterMaps
          .map((c) => TranscriptChapter.fromMap(c))
          .toList();
      tracks.add(AudioTrack.fromMap(map, chapters));
    }
    return tracks;
  }

  @override
  Future<void> purgeOfflineCache() async {
    final db = await _appDatabase.database;
    await db.update('tracks', {'isDownloaded': 0, 'isCached': 0});
  }
}
