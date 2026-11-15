import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../../../domain/entities/live_room.dart';
import '../bloc/live_room_bloc.dart';
import 'widgets/speaker_avatar_badge.dart';

class LiveStageView extends StatefulWidget {
  final String roomId;

  const LiveStageView({super.key, required this.roomId});

  @override
  State<LiveStageView> createState() => _LiveStageViewState();
}

class _LiveStageViewState extends State<LiveStageView> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _stageScrollController = ScrollController();
  final ScrollController _chatScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<LiveRoomBloc>().add(SelectLiveRoomEvent(widget.roomId));
  }

  @override
  void dispose() {
    _chatController.dispose();
    _stageScrollController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _sendChatMessage(BuildContext context) {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    context.read<LiveRoomBloc>().add(
      SendChatMessageEvent(
        roomId: widget.roomId,
        message: text,
        senderName: 'Safeer Hussain',
      ),
    );
    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<LiveRoomBloc, LiveRoomState>(
      builder: (context, state) {
        final room = state.activeRoom;
        if (room == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Live Audio Studio')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (isLandscape) {
          // 360dp Landscape Two-Pane Layout
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              toolbarHeight: 36.0,
              title: Text(
                room.title,
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                _buildLiveBadge(context, room.listenerCount),
                const SizedBox(width: 8.0),
              ],
            ),
            body: SafeArea(
              child: Row(
                children: [
                  // Left Pane: Stage Grid & Reactions
                  Expanded(
                    flex: 7,
                    child: SingleChildScrollView(
                      controller: _stageScrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStageHeader(context, room),
                          const SizedBox(height: 10.0),
                          _buildSpeakersGrid(context, room, isLandscape: true),
                          const SizedBox(height: 12.0),
                          _buildActionControls(context, room),
                        ],
                      ),
                    ),
                  ),
                  VerticalDivider(
                    width: 1.0,
                    color: colorScheme.outlineVariant,
                  ),
                  // Right Pane: Live Room Chat
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            12.0,
                            8.0,
                            12.0,
                            4.0,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 16.0,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                'Stage Backchannel Chat',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: _buildChatList(context, room)),
                        _buildChatInput(context),
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
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            elevation: 0,
            title: Text(
              room.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              _buildLiveBadge(context, room.listenerCount),
              const SizedBox(width: 12.0),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _stageScrollController,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStageHeader(context, room),
                        const SizedBox(height: 16.0),
                        _buildSpeakersGrid(context, room, isLandscape: false),
                        const SizedBox(height: 16.0),
                        Text(
                          'Stage Discussions & Chat',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          height: 180.0,
                          child: _buildChatList(context, room),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildChatInput(context),
                _buildActionControls(context, room),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveBadge(BuildContext context, int listeners) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(width: 4.0),
          Text(
            '$listeners LIVE',
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.w800,
              color: colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageHeader(BuildContext context, LiveRoom room) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.0,
            backgroundImage: AssetImage(room.hostAvatar),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hosted by ${room.hostName}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Topic: ${room.topicTag} • Spatial Binaural Stage',
                  style: TextStyle(
                    fontSize: 11.0,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakersGrid(
    BuildContext context,
    LiveRoom room, {
    required bool isLandscape,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Speakers Stage (${room.speakers.length})',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: colorScheme.primary,
                ),
              ),
              if (room.isUserSpeaking)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    'YOU ARE SPEAKING',
                    style: TextStyle(
                      fontSize: 9.0,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10.0),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: room.speakers.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLandscape ? 4 : 3,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              mainAxisExtent: 145.0, // Strict adherence to Rule 3!
            ),
            itemBuilder: (context, index) {
              return SpeakerAvatarBadge(speaker: room.speakers[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionControls(BuildContext context, LiveRoom room) {
    final colorScheme = Theme.of(context).colorScheme;
    final bloc = context.read<LiveRoomBloc>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Raise Hand Button (promotes to Speakers stage!)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: room.isUserSpeaking
                  ? colorScheme.secondary
                  : room.isUserHandRaised
                  ? colorScheme.tertiary
                  : colorScheme.primary,
            ),
            onPressed: () {
              bloc.add(ToggleRaiseHandEvent(widget.roomId));
              if (!room.isUserSpeaking) {
                AppFeedback.showSuccess(
                  context,
                  'Hand raised! Promoted directly to the Speakers Stage.',
                );
              }
            },
            icon: Icon(
              room.isUserSpeaking
                  ? Icons.mic_rounded
                  : Icons.front_hand_rounded,
              size: 16.0,
            ),
            label: Text(
              room.isUserSpeaking
                  ? 'On Stage'
                  : room.isUserHandRaised
                  ? 'Hand Raised'
                  : 'Raise Hand',
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Instant Reaction Bursts (Applaud, Insightful, Question)
          Row(
            children: [
              _buildReactionButton(
                context,
                icon: Icons.thumb_up_alt_rounded,
                count: room.reactionApplaud,
                label: 'Applaud',
                onTap: () {
                  bloc.add(SendReactionEvent(widget.roomId, 'applaud'));
                },
              ),
              const SizedBox(width: 8.0),
              _buildReactionButton(
                context,
                icon: Icons.lightbulb_rounded,
                count: room.reactionInsightful,
                label: 'Insight',
                onTap: () {
                  bloc.add(SendReactionEvent(widget.roomId, 'insightful'));
                },
              ),
              const SizedBox(width: 8.0),
              _buildReactionButton(
                context,
                icon: Icons.help_outline_rounded,
                count: room.reactionQuestion,
                label: 'Ask',
                onTap: () {
                  bloc.add(SendReactionEvent(widget.roomId, 'question'));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(
    BuildContext context, {
    required IconData icon,
    required int count,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.0, color: colorScheme.primary),
            const SizedBox(width: 4.0),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context, LiveRoom room) {
    final colorScheme = Theme.of(context).colorScheme;

    if (room.chatMessages.isEmpty) {
      return Center(
        child: Text(
          'No backchannel messages yet. Share your thoughts!',
          style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      controller: _chatScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      itemCount: room.chatMessages.length,
      itemBuilder: (context, index) {
        final msg = room.chatMessages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${msg.senderName}: ',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              Expanded(
                child: Text(
                  msg.message,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 4.0),
              Text(
                msg.timestamp,
                style: TextStyle(
                  fontSize: 9.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatInput(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              style: TextStyle(fontSize: 12.5, color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Send stage feedback or question...',
                hintStyle: TextStyle(
                  fontSize: 12.0,
                  color: colorScheme.onSurfaceVariant,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendChatMessage(context),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: Icon(
              Icons.send_rounded,
              color: colorScheme.primary,
              size: 20.0,
            ),
            onPressed: () => _sendChatMessage(context),
          ),
        ],
      ),
    );
  }
}
