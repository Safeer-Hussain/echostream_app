import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../domain/entities/live_room.dart';
import '../../domain/repositories/live_room_repository.dart';
import '../datasources/database/app_database.dart';

class LiveRoomRepositoryImpl implements LiveRoomRepository {
  final AppDatabase _appDatabase;
  final Map<String, List<LiveChatMessage>> _inMemoryChat = {};

  LiveRoomRepositoryImpl(this._appDatabase);

  @override
  Future<List<LiveRoom>> getLiveRooms() async {
    final db = await _appDatabase.database;
    final maps = await db.query('live_rooms');

    return maps.map((map) {
      final roomId = map['id'] as String;
      final rawSpeakers = map['speakersJson'] as String;
      List<LiveSpeaker> speakers = [];
      try {
        final decoded = jsonDecode(rawSpeakers) as List<dynamic>;
        speakers = decoded
            .map((s) => LiveSpeaker.fromMap(s as Map<String, dynamic>))
            .toList();
      } catch (_) {}

      return LiveRoom(
        id: roomId,
        title: map['title'] as String,
        hostName: map['hostName'] as String,
        hostAvatar: map['hostAvatar'] as String,
        topicTag: map['topicTag'] as String,
        listenerCount: (map['listenerCount'] as num).toInt(),
        isLive: (map['isLive'] as num) == 1,
        isUserSpeaking: (map['isUserSpeaking'] as num) == 1,
        isUserHandRaised: (map['isUserHandRaised'] as num) == 1,
        reactionApplaud: (map['reactionApplaud'] as num).toInt(),
        reactionInsightful: (map['reactionInsightful'] as num).toInt(),
        reactionQuestion: (map['reactionQuestion'] as num).toInt(),
        speakers: speakers,
        chatMessages: _inMemoryChat[roomId] ?? [],
      );
    }).toList();
  }

  @override
  Future<LiveRoom?> getRoomById(String id) async {
    final rooms = await getLiveRooms();
    try {
      return rooms.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> hostRoom({
    required String title,
    required String topicTag,
    required String hostName,
  }) async {
    final db = await _appDatabase.database;
    final roomId = 'room_${DateTime.now().millisecondsSinceEpoch}';
    final hostSpeaker = LiveSpeaker(
      id: 'spk_host_${DateTime.now().millisecondsSinceEpoch}',
      name: hostName,
      role: 'Host',
      avatarAsset: 'assets/images/avatar_host_2.png',
      isSpeaking: true,
      isMuted: false,
    );

    final map = {
      'id': roomId,
      'title': title,
      'hostName': hostName,
      'hostAvatar': 'assets/images/avatar_host_2.png',
      'topicTag': topicTag,
      'listenerCount': 1,
      'isLive': 1,
      'isUserSpeaking': 1,
      'isUserHandRaised': 0,
      'reactionApplaud': 0,
      'reactionInsightful': 0,
      'reactionQuestion': 0,
      'speakersJson': jsonEncode([hostSpeaker.toMap()]),
    };

    await db.insert(
      'live_rooms',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> toggleRaiseHand(String roomId, bool raised) async {
    final db = await _appDatabase.database;
    await db.update(
      'live_rooms',
      {'isUserHandRaised': raised ? 1 : 0},
      where: 'id = ?',
      whereArgs: [roomId],
    );
  }

  @override
  Future<void> promoteToSpeaker(String roomId, String participantName) async {
    final db = await _appDatabase.database;
    final room = await getRoomById(roomId);
    if (room == null) return;

    final newSpeaker = LiveSpeaker(
      id: 'spk_${DateTime.now().millisecondsSinceEpoch}',
      name: participantName,
      role: 'Speaker',
      avatarAsset: 'assets/images/avatar_host_2.png',
      isSpeaking: true,
      isMuted: false,
    );

    final updatedSpeakers = List<LiveSpeaker>.from(room.speakers)
      ..add(newSpeaker);
    final rawSpeakers = jsonEncode(
      updatedSpeakers.map((s) => s.toMap()).toList(),
    );

    await db.update(
      'live_rooms',
      {'isUserSpeaking': 1, 'isUserHandRaised': 0, 'speakersJson': rawSpeakers},
      where: 'id = ?',
      whereArgs: [roomId],
    );
  }

  @override
  Future<void> incrementReaction(String roomId, String reactionType) async {
    final db = await _appDatabase.database;
    final column = reactionType == 'applaud'
        ? 'reactionApplaud'
        : reactionType == 'insightful'
        ? 'reactionInsightful'
        : 'reactionQuestion';

    await db.rawUpdate(
      'UPDATE live_rooms SET $column = $column + 1 WHERE id = ?',
      [roomId],
    );
  }

  @override
  Future<void> sendChatMessage(String roomId, LiveChatMessage message) async {
    _inMemoryChat.putIfAbsent(roomId, () => []);
    _inMemoryChat[roomId]!.add(message);
  }
}
