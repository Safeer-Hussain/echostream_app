class TimestampClip {
  final String id;
  final String trackId;
  final String trackTitle;
  final int timestampSec;
  final String noteText;
  final String createdAt;

  const TimestampClip({
    required this.id,
    required this.trackId,
    required this.trackTitle,
    required this.timestampSec,
    required this.noteText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackId': trackId,
      'trackTitle': trackTitle,
      'timestampSec': timestampSec,
      'noteText': noteText,
      'createdAt': createdAt,
    };
  }

  factory TimestampClip.fromMap(Map<String, dynamic> map) {
    return TimestampClip(
      id: map['id'] as String,
      trackId: map['trackId'] as String,
      trackTitle: map['trackTitle'] as String,
      timestampSec: (map['timestampSec'] as num).toInt(),
      noteText: map['noteText'] as String,
      createdAt: map['createdAt'] as String,
    );
  }
}
