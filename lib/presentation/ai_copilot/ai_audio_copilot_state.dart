import 'package:equatable/equatable.dart';

class CopilotChatMessage extends Equatable {
  final String id;
  final String sender; // 'user' or 'copilot'
  final String text;
  final String timestamp;
  final List<String> sourceCitations;

  const CopilotChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.sourceCitations = const [],
  });

  CopilotChatMessage copyWith({
    String? id,
    String? sender,
    String? text,
    String? timestamp,
    List<String>? sourceCitations,
  }) {
    return CopilotChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      sourceCitations: sourceCitations ?? this.sourceCitations,
    );
  }

  @override
  List<Object?> get props => [id, sender, text, timestamp, sourceCitations];
}

class AiAudioCopilotState extends Equatable {
  final List<CopilotChatMessage> messages;
  final bool isStreaming;
  final String currentStreamingChunk;
  final String statusIndicatorText;

  const AiAudioCopilotState({
    this.messages = const [],
    this.isStreaming = false,
    this.currentStreamingChunk = '',
    this.statusIndicatorText = '',
  });

  AiAudioCopilotState copyWith({
    List<CopilotChatMessage>? messages,
    bool? isStreaming,
    String? currentStreamingChunk,
    String? statusIndicatorText,
  }) {
    return AiAudioCopilotState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      currentStreamingChunk:
          currentStreamingChunk ?? this.currentStreamingChunk,
      statusIndicatorText: statusIndicatorText ?? this.statusIndicatorText,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    isStreaming,
    currentStreamingChunk,
    statusIndicatorText,
  ];
}
