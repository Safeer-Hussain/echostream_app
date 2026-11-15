import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../player/bloc/audio_player_bloc.dart';
import 'ai_audio_copilot_cubit.dart';
import 'ai_audio_copilot_state.dart';

class AiAudioCopilotView extends StatefulWidget {
  const AiAudioCopilotView({super.key});

  @override
  State<AiAudioCopilotView> createState() => _AiAudioCopilotViewState();
}

class _AiAudioCopilotViewState extends State<AiAudioCopilotView> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final ScrollController _shortcutsScrollController = ScrollController();

  final List<String> _promptShortcuts = [
    'Summarize Key Takeaways From Current Episode',
    'Compile Action Items From My Timestamp Clips',
    'Recommend Next Deep-Focus Session',
    'Audit My Weekly Listening Habits',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    _chatScrollController.dispose();
    _shortcutsScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendPrompt(String text) {
    if (text.trim().isEmpty) return;
    final activeTrack = context.read<AudioPlayerBloc>().state.currentTrack;
    context.read<AiAudioCopilotCubit>().sendUserPrompt(
      text,
      activeTrack: activeTrack,
    );
    _promptController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<AiAudioCopilotCubit, AiAudioCopilotState>(
      listener: (context, state) {
        _scrollToBottom();
      },
      builder: (context, state) {
        final messages = state.messages;

        if (isLandscape) {
          // 360dp Landscape Two-Pane Layout
          return Scaffold(
            resizeToAvoidBottomInset: true, // Strict Rule 4
            floatingActionButton: FloatingActionButton(
              heroTag: 'fab_ai_transcript_clear', // Strict Rule 2
              mini: true,
              onPressed: () {
                context.read<AiAudioCopilotCubit>().clearConversation();
              },
              child: const Icon(Icons.delete_sweep_rounded),
            ),
            body: SafeArea(
              child: Row(
                children: [
                  // Left Pane: Shortcuts & Context
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      controller: _shortcutsScrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildContextCard(context),
                          const SizedBox(height: 10.0),
                          Text(
                            'One-Tap Architectural Prompts',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          ..._promptShortcuts.map((shortcut) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: ActionChip(
                                label: Text(
                                  shortcut,
                                  style: const TextStyle(fontSize: 11.0),
                                ),
                                onPressed: state.isStreaming
                                    ? null
                                    : () => _sendPrompt(shortcut),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 1.0,
                    color: colorScheme.outlineVariant,
                  ),
                  // Right Pane: Messages & Docked Input Bar
                  Expanded(
                    flex: 8,
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildMessagesList(context, state, messages),
                        ),
                        if (state.isStreaming)
                          _buildStreamingIndicator(context, state),
                        _buildInputBar(context, state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Portrait Layout
        return Scaffold(
          resizeToAvoidBottomInset: true, // Strict Rule 4
          floatingActionButton: FloatingActionButton(
            heroTag: 'fab_ai_transcript_clear', // Strict Rule 2
            mini: true,
            onPressed: () {
              context.read<AiAudioCopilotCubit>().clearConversation();
            },
            child: const Icon(Icons.delete_sweep_rounded),
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildShortcutsBar(context, state),
                Expanded(child: _buildMessagesList(context, state, messages)),
                if (state.isStreaming) _buildStreamingIndicator(context, state),
                _buildInputBar(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContextCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeTrack = context.read<AudioPlayerBloc>().state.currentTrack;

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.memory_rounded,
                size: 14.0,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 4.0),
              Text(
                'On-Device SQLite Context',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            activeTrack != null
                ? 'Active Stream: "${activeTrack.title}"'
                : 'Indexing 24 SQLite tracks & clips',
            style: TextStyle(
              fontSize: 11.0,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutsBar(BuildContext context, AiAudioCopilotState state) {
    return SizedBox(
      height: 44.0,
      child: ListView.separated(
        controller: _shortcutsScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
        itemCount: _promptShortcuts.length,
        separatorBuilder: (context, i) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final shortcut = _promptShortcuts[index];
          return ActionChip(
            label: Text(shortcut, style: const TextStyle(fontSize: 11.5)),
            onPressed: state.isStreaming ? null : () => _sendPrompt(shortcut),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(
    BuildContext context,
    AiAudioCopilotState state,
    List<CopilotChatMessage> messages,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      controller: _chatScrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      itemCount: messages.length + (state.isStreaming ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && state.isStreaming) {
          return _buildStreamingBubble(context, state.currentStreamingChunk);
        }

        final msg = messages[index];
        final isUser = msg.sender == 'user';

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? colorScheme.primary
                  : colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14.0).copyWith(
                bottomRight: isUser ? const Radius.circular(2.0) : null,
                bottomLeft: !isUser ? const Radius.circular(2.0) : null,
              ),
              border: Border.all(
                color: isUser
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: TextStyle(
                    fontSize: 13.0,
                    height: 1.4,
                    color: isUser
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.timestamp,
                      style: TextStyle(
                        fontSize: 10.0,
                        color: isUser
                            ? colorScheme.onPrimary.withOpacity(0.7)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (!isUser && msg.sourceCitations.isNotEmpty) ...[
                  const SizedBox(height: 6.0),
                  Wrap(
                    spacing: 4.0,
                    children: msg.sourceCitations.map((cite) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          cite,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreamingBubble(BuildContext context, String chunk) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14.0),
            topRight: Radius.circular(14.0),
            bottomRight: Radius.circular(14.0),
            bottomLeft: Radius.circular(2.0),
          ),
          border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
        ),
        child: Text(
          chunk.isEmpty ? '...' : chunk,
          style: TextStyle(
            fontSize: 13.0,
            height: 1.4,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildStreamingIndicator(
    BuildContext context,
    AiAudioCopilotState state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Row(
        children: [
          SizedBox(
            width: 12.0,
            height: 12.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              state.statusIndicatorText,
              style: TextStyle(
                fontSize: 11.0,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, AiAudioCopilotState state) {
    final colorScheme = Theme.of(context).colorScheme;

    // Strict Rule 4: Rely on Scaffold(resizeToAvoidBottomInset: true) + SafeArea(top: false)
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promptController,
                style: TextStyle(fontSize: 13.0, color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Ask Copilot about transcripts, clips, EQ...',
                  hintStyle: TextStyle(
                    fontSize: 12.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: state.isStreaming ? null : _sendPrompt,
              ),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              icon: Icon(
                Icons.arrow_upward_rounded,
                color: state.isStreaming
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.primary,
              ),
              onPressed: state.isStreaming
                  ? null
                  : () => _sendPrompt(_promptController.text),
            ),
          ],
        ),
      ),
    );
  }
}
