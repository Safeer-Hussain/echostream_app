import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_feedback.dart';
import '../../player/bloc/audio_player_bloc.dart';
import '../bloc/vault_bloc.dart';
import 'modals/create_playlist_modal.dart';

class VaultView extends StatefulWidget {
  const VaultView({super.key});

  @override
  State<VaultView> createState() => _VaultViewState();
}

class _VaultViewState extends State<VaultView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _vaultScrollController = ScrollController();
  final ScrollController _playlistScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<VaultBloc>().add(LoadVaultDataEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _vaultScrollController.dispose();
    _playlistScrollController.dispose();
    super.dispose();
  }

  void _showCreatePlaylistModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (_) => CreatePlaylistModal(vaultBloc: context.read<VaultBloc>()),
    );
  }

  void _confirmPurgeCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Theme.of(dialogCtx).colorScheme.surfaceContainer,
        title: Text(
          'Purge Offline Vault Cache?',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            color: Theme.of(dialogCtx).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'This will remove all downloaded lossless FLAC tracks from your local device storage. Tracks can be re-downloaded at any time.',
          style: TextStyle(
            fontSize: 13.0,
            color: Theme.of(dialogCtx).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(dialogCtx).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogCtx).colorScheme.error,
              foregroundColor: Theme.of(dialogCtx).colorScheme.onError,
            ),
            onPressed: () {
              context.read<VaultBloc>().add(PurgeCacheEvent());
              Navigator.of(dialogCtx).pop();
              AppFeedback.showSuccess(
                context,
                'Offline vault cache purged successfully.',
              );
            },
            child: const Text('Purge All Cache'),
          ),
        ],
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
        heroTag: 'fab_create_playlist', // Strict Rule 2 requirement!
        onPressed: () => _showCreatePlaylistModal(context),
        icon: const Icon(Icons.playlist_add_rounded),
        label: const Text('New Playlist'),
      ),
      body: BlocBuilder<VaultBloc, VaultState>(
        builder: (context, state) {
          return Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: colorScheme.primary,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                labelStyle: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w700,
                ),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.download_done_rounded, size: 20.0),
                    text: 'Offline Vault (${state.downloadedTracks.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.queue_music_rounded, size: 20.0),
                    text: 'Playlists (${state.playlists.length})',
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOfflineVaultTab(context, state, isLandscape),
                    _buildPlaylistsTab(context, state, isLandscape),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOfflineVaultTab(
    BuildContext context,
    VaultState state,
    bool isLandscape,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.downloadedTracks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_download_outlined,
                size: 48.0,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12.0),
              Text(
                'Your Offline Vault is Empty',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Save lossless engineering tracks from Discovery to listen anywhere with zero network dependency.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.0,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalGb = state.totalStorageMb / 1024.0;

    return SingleChildScrollView(
      controller: _vaultScrollController,
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Storage Breakdown Card
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
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
                      'Offline Storage Footprint',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: colorScheme.error,
                      ),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16.0,
                      ),
                      label: const Text(
                        'Purge Cache',
                        style: TextStyle(fontSize: 11.5),
                      ),
                      onPressed: () => _confirmPurgeCache(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    Text(
                      '${state.totalStorageMb} MB',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '(${totalGb.toStringAsFixed(2)} GB / 10 GB Vault Quota)',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                LinearProgressIndicator(
                  value: (state.totalStorageMb / 10240.0).clamp(0.01, 1.0),
                  minHeight: 5.0,
                  borderRadius: BorderRadius.circular(2.5),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14.0),
          Text(
            'Downloaded Lossless Sessions (${state.downloadedTracks.length})',
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8.0),
          ...state.downloadedTracks.map((track) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      track.coverAsset,
                      width: 44.0,
                      height: 44.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '${track.sampleRate} • ${track.fileSizeMb} MB FLAC Master',
                    style: TextStyle(
                      fontSize: 11.0,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.play_circle_fill_rounded,
                      color: colorScheme.primary,
                      size: 30.0,
                    ),
                    onPressed: () {
                      context.read<AudioPlayerBloc>().add(
                        LoadTrackEvent(track),
                      );
                    },
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab(
    BuildContext context,
    VaultState state,
    bool isLandscape,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.playlists.isEmpty) {
      return Center(
        child: Text(
          'No custom playlists created. Tap "New Playlist" to create one!',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      controller: _playlistScrollController,
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 80.0),
      itemCount: state.playlists.length,
      itemBuilder: (context, index) {
        final playlist = state.playlists[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 6.0,
              ),
              leading: Container(
                width: 46.0,
                height: 46.0,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.playlist_play_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 28.0,
                ),
              ),
              title: Text(
                playlist.title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    '${playlist.trackIds.length} tracks • Created ${playlist.createdAt}',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.0,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  AppFeedback.showInfo(
                    context,
                    'Playlist "${playlist.title}" loaded with ${playlist.trackIds.length} tracks.',
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
