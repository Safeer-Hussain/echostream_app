import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../domain/entities/dsp_preset.dart';
import '../../../domain/entities/playlist.dart';
import '../../../domain/entities/timestamp_clip.dart';
import '../mock_audio_catalog.dart';

class AppDatabase {
  static const String _dbName = 'echostream_vault.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedInitialData(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE tracks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        album TEXT NOT NULL,
        coverAsset TEXT NOT NULL,
        durationSec INTEGER NOT NULL,
        genre TEXT NOT NULL,
        sampleRate TEXT NOT NULL,
        bitDepth TEXT NOT NULL,
        format TEXT NOT NULL,
        isLossless INTEGER NOT NULL,
        isDownloaded INTEGER NOT NULL,
        fileSizeMb REAL NOT NULL,
        isLiked INTEGER NOT NULL,
        isCached INTEGER NOT NULL,
        playbackProgressSec INTEGER NOT NULL,
        transcriptText TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE chapters (
        id TEXT PRIMARY KEY,
        trackId TEXT NOT NULL,
        title TEXT NOT NULL,
        startTimeSec INTEGER NOT NULL,
        endTimeSec INTEGER NOT NULL,
        summary TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE timestamp_clips (
        id TEXT PRIMARY KEY,
        trackId TEXT NOT NULL,
        trackTitle TEXT NOT NULL,
        timestampSec INTEGER NOT NULL,
        noteText TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE live_rooms (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        hostName TEXT NOT NULL,
        hostAvatar TEXT NOT NULL,
        topicTag TEXT NOT NULL,
        listenerCount INTEGER NOT NULL,
        isLive INTEGER NOT NULL,
        isUserSpeaking INTEGER NOT NULL,
        isUserHandRaised INTEGER NOT NULL,
        reactionApplaud INTEGER NOT NULL,
        reactionInsightful INTEGER NOT NULL,
        reactionQuestion INTEGER NOT NULL,
        speakersJson TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE playlists (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        trackIdsJson TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_eq_presets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        bandsJson TEXT NOT NULL,
        isSystemPreset INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE listening_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trackId TEXT NOT NULL,
        listenedSec INTEGER NOT NULL,
        genre TEXT NOT NULL,
        dayOfWeek TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedInitialData(Database db) async {
    final seedTracks = MockAudioCatalog.getSeedTracks();
    for (final track in seedTracks) {
      await db.insert(
        'tracks',
        track.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final chapter in track.chapters) {
        await db.insert(
          'chapters',
          chapter.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    // Seed default timestamp clips
    final sampleClips = [
      TimestampClip(
        id: 'clip_01',
        trackId: 'track_01',
        trackTitle: 'Ambient Architecture: Spatial Soundscapes',
        timestampSec: 420,
        noteText: 'Modal resonance is mitigated with corner bass trapping.',
        createdAt: '2026-11-14 14:32',
      ),
      TimestampClip(
        id: 'clip_02',
        trackId: 'track_02',
        trackTitle: 'Systems Engineering: LLVM & Compilers',
        timestampSec: 1520,
        noteText:
            'SLP vectorizer groups scalar audio DSP loads into SIMD NEON.',
        createdAt: '2026-11-15 09:15',
      ),
    ];
    for (final clip in sampleClips) {
      await db.insert(
        'timestamp_clips',
        clip.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Seed default Live Rooms
    final sampleRooms = [
      {
        'id': 'room_01',
        'title': 'High-Performance Audio DSP & SIMD Pipelines',
        'hostName': 'Dr. Sarah Lin',
        'hostAvatar': 'assets/images/avatar_host_1.png',
        'topicTag': 'DSP & Compilers',
        'listenerCount': 142,
        'isLive': 1,
        'isUserSpeaking': 0,
        'isUserHandRaised': 0,
        'reactionApplaud': 256,
        'reactionInsightful': 184,
        'reactionQuestion': 32,
        'speakersJson': jsonEncode([
          {
            'id': 'spk_1',
            'name': 'Dr. Sarah Lin',
            'role': 'Host',
            'avatarAsset': 'assets/images/avatar_host_1.png',
            'isSpeaking': true,
            'isMuted': false,
          },
          {
            'id': 'spk_2',
            'name': 'Safeer Hussain',
            'role': 'Mobile Architect',
            'avatarAsset': 'assets/images/avatar_host_2.png',
            'isSpeaking': false,
            'isMuted': false,
          },
          {
            'id': 'spk_3',
            'name': 'Elena Rostova',
            'role': 'Acoustics Lead',
            'avatarAsset': 'assets/images/avatar_host_3.png',
            'isSpeaking': false,
            'isMuted': true,
          },
        ]),
      },
      {
        'id': 'room_02',
        'title': 'Frontier Reasoning Models & Quantized NPU Inference',
        'hostName': 'Marcus Kane',
        'hostAvatar': 'assets/images/avatar_host_4.png',
        'topicTag': 'On-Device AI',
        'listenerCount': 289,
        'isLive': 1,
        'isUserSpeaking': 0,
        'isUserHandRaised': 0,
        'reactionApplaud': 512,
        'reactionInsightful': 420,
        'reactionQuestion': 78,
        'speakersJson': jsonEncode([
          {
            'id': 'spk_4',
            'name': 'Marcus Kane',
            'role': 'Host',
            'avatarAsset': 'assets/images/avatar_host_4.png',
            'isSpeaking': true,
            'isMuted': false,
          },
          {
            'id': 'spk_5',
            'name': 'Dr. Sarah Lin',
            'role': 'AI Fellow',
            'avatarAsset': 'assets/images/avatar_host_1.png',
            'isSpeaking': false,
            'isMuted': false,
          },
        ]),
      },
      {
        'id': 'room_03',
        'title': 'Lossless Spatial Audio & Binaural HRTF Mastering',
        'hostName': 'Elena Rostova',
        'hostAvatar': 'assets/images/avatar_host_3.png',
        'topicTag': 'Spatial Audio',
        'listenerCount': 94,
        'isLive': 1,
        'isUserSpeaking': 0,
        'isUserHandRaised': 0,
        'reactionApplaud': 189,
        'reactionInsightful': 95,
        'reactionQuestion': 14,
        'speakersJson': jsonEncode([
          {
            'id': 'spk_6',
            'name': 'Elena Rostova',
            'role': 'Host',
            'avatarAsset': 'assets/images/avatar_host_3.png',
            'isSpeaking': true,
            'isMuted': false,
          },
        ]),
      },
    ];
    for (final room in sampleRooms) {
      await db.insert(
        'live_rooms',
        room,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Seed default Playlists
    final defaultPlaylists = [
      Playlist(
        id: 'playlist_01',
        title: 'Deep Architecture & Compilers',
        description:
            'Selected podcasts on LLVM, Rust, and systems engineering.',
        trackIds: ['track_02', 'track_09', 'track_14', 'track_15'],
        createdAt: '2026-11-10',
      ),
      Playlist(
        id: 'playlist_02',
        title: 'Lossless Spatial Study Sessions',
        description:
            '24-bit 192kHz acoustic recordings for uninterrupted coding focus.',
        trackIds: ['track_01', 'track_03', 'track_06', 'track_07', 'track_17'],
        createdAt: '2026-11-12',
      ),
    ];
    for (final pl in defaultPlaylists) {
      await db.insert(
        'playlists',
        pl.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Seed system DSP presets
    for (final preset in DspPreset.defaultPresets) {
      await db.insert(
        'custom_eq_presets',
        preset.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Seed listening history records
    final historySamples = [
      {
        'trackId': 'track_01',
        'listenedSec': 3600,
        'genre': 'Deep Focus',
        'dayOfWeek': 'Mon',
      },
      {
        'trackId': 'track_02',
        'listenedSec': 4800,
        'genre': 'Systems & AI',
        'dayOfWeek': 'Tue',
      },
      {
        'trackId': 'track_05',
        'listenedSec': 5400,
        'genre': 'Systems & AI',
        'dayOfWeek': 'Wed',
      },
      {
        'trackId': 'track_06',
        'listenedSec': 3200,
        'genre': 'Lossless Master',
        'dayOfWeek': 'Thu',
      },
      {
        'trackId': 'track_07',
        'listenedSec': 4100,
        'genre': 'Acoustic',
        'dayOfWeek': 'Fri',
      },
      {
        'trackId': 'track_08',
        'listenedSec': 6200,
        'genre': 'Tech Keynotes',
        'dayOfWeek': 'Sat',
      },
      {
        'trackId': 'track_03',
        'listenedSec': 5100,
        'genre': 'Deep Focus',
        'dayOfWeek': 'Sun',
      },
    ];
    for (final item in historySamples) {
      await db.insert('listening_history', item);
    }
  }

  Future<void> seedIfEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM tracks'),
    );
    if (count == null || count == 0) {
      await _seedInitialData(db);
    }
  }
}
