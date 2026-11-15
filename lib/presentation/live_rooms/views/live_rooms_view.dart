import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/live_room.dart';
import '../bloc/live_room_bloc.dart';
import 'live_stage_view.dart';

class LiveRoomsView extends StatefulWidget {
  const LiveRoomsView({super.key});

  @override
  State<LiveRoomsView> createState() => _LiveRoomsViewState();
}

class _LiveRoomsViewState extends State<LiveRoomsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<LiveRoomBloc>().add(LoadLiveRoomsEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showHostRoomModal(BuildContext context) {
    final titleController = TextEditingController();
    final nameController = TextEditingController(text: 'Safeer Hussain');
    String selectedTopic = 'DSP & Compilers';
    String? titleError;
    String? nameError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (context, setModalState) {
          final colorScheme = Theme.of(context).colorScheme;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 36.0,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Host Live Audio Room Studio',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Launch an interactive spatial audio stage for engineers and creators.',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Room Topic & Title',
                        hintText: 'e.g., Real-Time Audio DSP Architectures',
                        errorText: titleError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Host Name',
                        errorText: nameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      'Stage Category Tag',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Wrap(
                      spacing: 8.0,
                      children:
                          [
                            'DSP & Compilers',
                            'On-Device AI',
                            'Spatial Audio',
                            'Lossless Master',
                          ].map((topic) {
                            final isSel = selectedTopic == topic;
                            return ChoiceChip(
                              label: Text(
                                topic,
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              selected: isSel,
                              onSelected: (_) {
                                setModalState(() {
                                  selectedTopic = topic;
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.podcasts_rounded),
                        label: const Text('Go Live on Stage'),
                        onPressed: () {
                          final title = titleController.text.trim();
                          final host = nameController.text.trim();

                          bool valid = true;
                          setModalState(() {
                            if (title.length < 4) {
                              titleError = 'Room title must be at least 4 characters long';
                              valid = false;
                            } else {
                              titleError = null;
                            }
                            if (host.isEmpty) {
                              nameError = 'Host name cannot be empty';
                              valid = false;
                            } else {
                              nameError = null;
                            }
                          });

                          if (valid) {
                            context.read<LiveRoomBloc>().add(
                              HostLiveRoomEvent(
                                title: title,
                                topicTag: selectedTopic,
                                hostName: host,
                              ),
                            );
                            Navigator.of(sheetCtx).pop();
                            AppFeedback.showSuccess(
                              context,
                              'Live Audio Room "$title" launched successfully!',
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_host_live_room', // Strict Rule 2 requirement!
        onPressed: () => _showHostRoomModal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Host Live Room'),
      ),
      body: BlocBuilder<LiveRoomBloc, LiveRoomState>(
        builder: (context, state) {
          final rooms = state.rooms;

          if (state.isLoading && rooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (rooms.isEmpty) {
            return Center(
              child: Text(
                'No live audio rooms active. Tap + to host one!',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            );
          }

          if (isLandscape) {
            return GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              itemCount: rooms.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                mainAxisExtent: 145.0, // Strict Rule 3 requirement!
              ),
              itemBuilder: (context, index) {
                return _buildRoomCard(context, rooms[index]);
              },
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 80.0),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              return _buildRoomCard(context, rooms[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, LiveRoom room) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LiveStageView(roomId: room.id)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20.0,
                      backgroundImage: AssetImage(room.hostAvatar),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
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
                                  room.topicTag,
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0,
                                  vertical: 2.0,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5.0,
                                      height: 5.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colorScheme.error,
                                      ),
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      '${room.listenerCount} LIVE',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            room.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Hosted by ${room.hostName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 13.0,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          '${room.reactionApplaud}',
                          style: TextStyle(
                            fontSize: 11.0,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Icon(
                          Icons.mic_none_rounded,
                          size: 13.0,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 3.0),
                        Text(
                          '${room.speakers.length} speakers',
                          style: TextStyle(
                            fontSize: 11.0,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
