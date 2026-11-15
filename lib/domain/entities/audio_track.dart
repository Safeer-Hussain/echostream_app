import 'transcript_chapter.dart';

class AudioTrack {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String coverAsset;
  final int durationSec;
  final String genre;
  final String sampleRate;
  final String bitDepth;
  final String format;
  final bool isLossless;
  final bool isDownloaded;
  final double fileSizeMb;
  final bool isLiked;
  final bool isCached;
  final int playbackProgressSec;
  final String transcriptText;
  final List<TranscriptChapter> chapters;

  const AudioTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.coverAsset,
    required this.durationSec,
    required this.genre,
    required this.sampleRate,
    required this.bitDepth,
    required this.format,
    required this.isLossless,
    required this.isDownloaded,
    required this.fileSizeMb,
    required this.isLiked,
    required this.isCached,
    required this.playbackProgressSec,
    required this.transcriptText,
    this.chapters = const [],
  });

  AudioTrack copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? coverAsset,
    int? durationSec,
    String? genre,
    String? sampleRate,
    String? bitDepth,
    String? format,
    bool? isLossless,
    bool? isDownloaded,
    double? fileSizeMb,
    bool? isLiked,
    bool? isCached,
    int? playbackProgressSec,
    String? transcriptText,
    List<TranscriptChapter>? chapters,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      coverAsset: coverAsset ?? this.coverAsset,
      durationSec: durationSec ?? this.durationSec,
      genre: genre ?? this.genre,
      sampleRate: sampleRate ?? this.sampleRate,
      bitDepth: bitDepth ?? this.bitDepth,
      format: format ?? this.format,
      isLossless: isLossless ?? this.isLossless,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      fileSizeMb: fileSizeMb ?? this.fileSizeMb,
      isLiked: isLiked ?? this.isLiked,
      isCached: isCached ?? this.isCached,
      playbackProgressSec: playbackProgressSec ?? this.playbackProgressSec,
      transcriptText: transcriptText ?? this.transcriptText,
      chapters: chapters ?? this.chapters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'coverAsset': coverAsset,
      'durationSec': durationSec,
      'genre': genre,
      'sampleRate': sampleRate,
      'bitDepth': bitDepth,
      'format': format,
      'isLossless': isLossless ? 1 : 0,
      'isDownloaded': isDownloaded ? 1 : 0,
      'fileSizeMb': fileSizeMb,
      'isLiked': isLiked ? 1 : 0,
      'isCached': isCached ? 1 : 0,
      'playbackProgressSec': playbackProgressSec,
      'transcriptText': transcriptText,
    };
  }

  factory AudioTrack.fromMap(
    Map<String, dynamic> map, [
    List<TranscriptChapter> chapters = const [],
  ]) {
    return AudioTrack(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String,
      coverAsset: map['coverAsset'] as String,
      durationSec: (map['durationSec'] as num).toInt(),
      genre: map['genre'] as String,
      sampleRate: map['sampleRate'] as String,
      bitDepth: map['bitDepth'] as String,
      format: map['format'] as String,
      isLossless: (map['isLossless'] as num) == 1,
      isDownloaded: (map['isDownloaded'] as num) == 1,
      fileSizeMb: (map['fileSizeMb'] as num).toDouble(),
      isLiked: (map['isLiked'] as num) == 1,
      isCached: (map['isCached'] as num) == 1,
      playbackProgressSec: (map['playbackProgressSec'] as num).toInt(),
      transcriptText: map['transcriptText'] as String,
      chapters: chapters,
    );
  }
}
