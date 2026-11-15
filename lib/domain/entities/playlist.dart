import 'dart:convert';

class Playlist {
  final String id;
  final String title;
  final String description;
  final List<String> trackIds;
  final String createdAt;

  const Playlist({
    required this.id,
    required this.title,
    required this.description,
    required this.trackIds,
    required this.createdAt,
  });

  Playlist copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? trackIds,
    String? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'trackIdsJson': jsonEncode(trackIds),
      'createdAt': createdAt,
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    List<String> tracks = [];
    final rawTracks = map['trackIdsJson'];
    if (rawTracks is String && rawTracks.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawTracks) as List<dynamic>;
        tracks = decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    return Playlist(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      trackIds: tracks,
      createdAt: map['createdAt'] as String,
    );
  }
}
