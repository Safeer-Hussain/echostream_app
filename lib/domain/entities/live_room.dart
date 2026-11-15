class LiveSpeaker {
  final String id;
  final String name;
  final String role;
  final String avatarAsset;
  final bool isSpeaking;
  final bool isMuted;

  const LiveSpeaker({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarAsset,
    required this.isSpeaking,
    required this.isMuted,
  });

  LiveSpeaker copyWith({
    String? id,
    String? name,
    String? role,
    String? avatarAsset,
    bool? isSpeaking,
    bool? isMuted,
  }) {
    return LiveSpeaker(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'avatarAsset': avatarAsset,
      'isSpeaking': isSpeaking,
      'isMuted': isMuted,
    };
  }

  factory LiveSpeaker.fromMap(Map<String, dynamic> map) {
    return LiveSpeaker(
      id: map['id'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      avatarAsset: map['avatarAsset'] as String,
      isSpeaking: map['isSpeaking'] as bool? ?? false,
      isMuted: map['isMuted'] as bool? ?? false,
    );
  }
}

class LiveChatMessage {
  final String id;
  final String senderName;
  final String message;
  final String timestamp;

  const LiveChatMessage({
    required this.id,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });
}

class LiveRoom {
  final String id;
  final String title;
  final String hostName;
  final String hostAvatar;
  final String topicTag;
  final int listenerCount;
  final bool isLive;
  final bool isUserSpeaking;
  final bool isUserHandRaised;
  final int reactionApplaud;
  final int reactionInsightful;
  final int reactionQuestion;
  final List<LiveSpeaker> speakers;
  final List<LiveChatMessage> chatMessages;

  const LiveRoom({
    required this.id,
    required this.title,
    required this.hostName,
    required this.hostAvatar,
    required this.topicTag,
    required this.listenerCount,
    required this.isLive,
    required this.isUserSpeaking,
    required this.isUserHandRaised,
    required this.reactionApplaud,
    required this.reactionInsightful,
    required this.reactionQuestion,
    required this.speakers,
    this.chatMessages = const [],
  });

  LiveRoom copyWith({
    String? id,
    String? title,
    String? hostName,
    String? hostAvatar,
    String? topicTag,
    int? listenerCount,
    bool? isLive,
    bool? isUserSpeaking,
    bool? isUserHandRaised,
    int? reactionApplaud,
    int? reactionInsightful,
    int? reactionQuestion,
    List<LiveSpeaker>? speakers,
    List<LiveChatMessage>? chatMessages,
  }) {
    return LiveRoom(
      id: id ?? this.id,
      title: title ?? this.title,
      hostName: hostName ?? this.hostName,
      hostAvatar: hostAvatar ?? this.hostAvatar,
      topicTag: topicTag ?? this.topicTag,
      listenerCount: listenerCount ?? this.listenerCount,
      isLive: isLive ?? this.isLive,
      isUserSpeaking: isUserSpeaking ?? this.isUserSpeaking,
      isUserHandRaised: isUserHandRaised ?? this.isUserHandRaised,
      reactionApplaud: reactionApplaud ?? this.reactionApplaud,
      reactionInsightful: reactionInsightful ?? this.reactionInsightful,
      reactionQuestion: reactionQuestion ?? this.reactionQuestion,
      speakers: speakers ?? this.speakers,
      chatMessages: chatMessages ?? this.chatMessages,
    );
  }
}
