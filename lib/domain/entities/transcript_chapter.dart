class TranscriptChapter {
  final String id;
  final String trackId;
  final String title;
  final int startTimeSec;
  final int endTimeSec;
  final String summary;

  const TranscriptChapter({
    required this.id,
    required this.trackId,
    required this.title,
    required this.startTimeSec,
    required this.endTimeSec,
    required this.summary,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackId': trackId,
      'title': title,
      'startTimeSec': startTimeSec,
      'endTimeSec': endTimeSec,
      'summary': summary,
    };
  }

  factory TranscriptChapter.fromMap(Map<String, dynamic> map) {
    return TranscriptChapter(
      id: map['id'] as String,
      trackId: map['trackId'] as String,
      title: map['title'] as String,
      startTimeSec: (map['startTimeSec'] as num).toInt(),
      endTimeSec: (map['endTimeSec'] as num).toInt(),
      summary: map['summary'] as String,
    );
  }
}
