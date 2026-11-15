import '../entities/live_room.dart';

abstract class LiveRoomRepository {
  Future<List<LiveRoom>> getLiveRooms();
  Future<LiveRoom?> getRoomById(String id);
  Future<void> hostRoom({
    required String title,
    required String topicTag,
    required String hostName,
  });
  Future<void> toggleRaiseHand(String roomId, bool raised);
  Future<void> promoteToSpeaker(String roomId, String participantName);
  Future<void> incrementReaction(String roomId, String reactionType);
  Future<void> sendChatMessage(String roomId, LiveChatMessage message);
}
