import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../core/network/mock_dio_interceptor.dart';
import '../core/services/service_locator.dart';
import 'ai_copilot/ai_audio_copilot_view.dart';
import 'discovery/views/discovery_view.dart';
import 'equalizer/views/equalizer_view.dart';
import 'live_rooms/views/live_rooms_view.dart';
import 'player/views/mini_player_bar.dart';
import 'profile_analytics/views/analytics_view.dart';
import 'profile_analytics/views/recruiter_debug_drawer.dart';
import 'vault/views/vault_view.dart';

class AdaptiveScaffold extends StatefulWidget {
  const AdaptiveScaffold({super.key});

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  int _currentIndex = 0;
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final List<String> _titles = [
    'EchoStream Discovery',
    'Live Audio Stage Studio',
    'Native 10-Band DSP Equalizer',
    'Offline Vault & Playlists',
    'On-Device AI Audio Copilot',
    'Listening Analytics & Hardware',
  ];

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  void _checkConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final offline =
          results.contains(ConnectivityResult.none) ||
          getIt<MockDioInterceptor>().simulateOffline;
      if (mounted) {
        setState(() {
          _isOffline = offline;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const DiscoveryView();
      case 1:
        return const LiveRoomsView();
      case 2:
        return const EqualizerView();
      case 3:
        return const VaultView();
      case 4:
        return const AiAudioCopilotView();
      case 5:
        return const AnalyticsView();
      default:
        return const DiscoveryView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;

    if (isLandscape) {
      // Strict Rule 3: Compact NavigationRail wrapped in SingleChildScrollView + IntrinsicHeight
      return Scaffold(
        endDrawer: const RecruiterDebugDrawer(),
        appBar: AppBar(
          toolbarHeight: 36.0, // Strict Rule 3: 36dp toolbarHeight
          title: Text(
            _titles[_currentIndex],
            style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _currentIndex == 5
                    ? Icons.analytics_rounded
                    : Icons.analytics_outlined,
                size: 18.0,
                color: _currentIndex == 5
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 5;
                });
              },
            ),
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.settings_outlined, size: 18.0),
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_isOffline) _buildOfflineBanner(context),
              Expanded(
                child: Row(
                  children: [
                    // SingleChildScrollView + IntrinsicHeight for 360dp landscape
                    SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: IntrinsicHeight(
                        child: NavigationRail(
                          minWidth: 56.0, // Strict Rule 3: 56dp minWidth
                          labelType:
                              NavigationRailLabelType.none, // No bulky labels
                          selectedIndex: _currentIndex > 4 ? 0 : _currentIndex,
                          onDestinationSelected: (idx) {
                            setState(() {
                              _currentIndex = idx;
                            });
                          },
                          destinations: const [
                            NavigationRailDestination(
                              icon: Icon(Icons.explore_outlined, size: 20.0),
                              selectedIcon: Icon(
                                Icons.explore_rounded,
                                size: 20.0,
                              ),
                              label: Text('Discovery'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.podcasts_outlined, size: 20.0),
                              selectedIcon: Icon(
                                Icons.podcasts_rounded,
                                size: 20.0,
                              ),
                              label: Text('Live Stage'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.equalizer_outlined, size: 20.0),
                              selectedIcon: Icon(
                                Icons.equalizer_rounded,
                                size: 20.0,
                              ),
                              label: Text('Equalizer'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(
                                Icons.folder_special_outlined,
                                size: 20.0,
                              ),
                              selectedIcon: Icon(
                                Icons.folder_special_rounded,
                                size: 20.0,
                              ),
                              label: Text('Vault'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(
                                Icons.auto_awesome_outlined,
                                size: 20.0,
                              ),
                              selectedIcon: Icon(
                                Icons.auto_awesome_rounded,
                                size: 20.0,
                              ),
                              label: Text('Copilot'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(
                      width: 1.0,
                      color: colorScheme.outlineVariant,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          _buildBody(_currentIndex),
                          const Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: MiniPlayerBar(),
                          ),
                        ],
                      ),
                    ),
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
      endDrawer: const RecruiterDebugDrawer(),
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _currentIndex == 5
                  ? Icons.analytics_rounded
                  : Icons.analytics_outlined,
              color: _currentIndex == 5
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 5;
              });
            },
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isOffline) _buildOfflineBanner(context),
            Expanded(
              child: Stack(
                children: [
                  _buildBody(_currentIndex),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: MiniPlayerBar(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex > 4 ? 0 : _currentIndex,
        onTap: (idx) {
          setState(() {
            _currentIndex = idx;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Discovery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.podcasts_outlined),
            activeIcon: Icon(Icons.podcasts_rounded),
            label: 'Live Rooms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.equalizer_outlined),
            activeIcon: Icon(Icons.equalizer_rounded),
            label: 'Equalizer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_special_outlined),
            activeIcon: Icon(Icons.folder_special_rounded),
            label: 'Vault',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Copilot',
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      color: colorScheme.tertiaryContainer,
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 16.0,
            color: colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              'Offline Vault Mode - Playing Cached Lossless Tracks & Podcasts from Local SQLite',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
