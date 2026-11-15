import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/app_feedback.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/analytics_repository.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  final ScrollController _leftScrollController = ScrollController();
  final ScrollController _rightScrollController = ScrollController();

  UserProfile? _profile;
  Map<String, double> _weeklyHours = {};
  Map<String, double> _genreDist = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = getIt<AnalyticsRepository>();
    final profile = await repo.getUserProfile();
    final weekly = await repo.getWeeklyListeningHours();
    final genre = await repo.getGenreDistribution();

    if (mounted) {
      setState(() {
        _profile = profile;
        _weeklyHours = weekly;
        _genreDist = genre;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _leftScrollController.dispose();
    _rightScrollController.dispose();
    super.dispose();
  }

  void _openDebugDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = _profile!;

    if (isLandscape) {
      // 360dp Landscape Two-Pane Layout
      return Row(
        children: [
          // Left Pane: Profile Card & Theme Switcher
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              controller: _leftScrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileCard(context, profile),
                  const SizedBox(height: 10.0),
                  _buildSettingsToggles(context),
                ],
              ),
            ),
          ),
          VerticalDivider(width: 1.0, color: colorScheme.outlineVariant),
          // Right Pane: Full-Width fl_chart Analytics
          Expanded(
            flex: 7,
            child: SingleChildScrollView(
              controller: _rightScrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWeeklyBarChart(context),
                  const SizedBox(height: 12.0),
                  _buildGenreDistribution(context),
                  const SizedBox(height: 12.0),
                  _buildAppFooter(context),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Portrait Layout
    return SingleChildScrollView(
      controller: _leftScrollController,
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileCard(context, profile),
          const SizedBox(height: 14.0),
          _buildSettingsToggles(context),
          const SizedBox(height: 16.0),
          _buildWeeklyBarChart(context),
          const SizedBox(height: 16.0),
          _buildGenreDistribution(context),
          const SizedBox(height: 20.0),
          _buildAppFooter(context),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserProfile profile) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26.0,
                backgroundImage: AssetImage(profile.avatarAsset),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${profile.handle} • ${profile.email}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4.0),
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
                        profile.audioHardwareTier,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildMetricColumn(
                  context,
                  label: 'Weekly Hours',
                  value: '${profile.weeklyHoursListened}h',
                  icon: Icons.timer_outlined,
                ),
              ),
              Expanded(
                child: _buildMetricColumn(
                  context,
                  label: 'Completed',
                  value: '${profile.totalTracksCompleted}',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              Expanded(
                child: _buildMetricColumn(
                  context,
                  label: 'Offline Vault',
                  value: '${profile.offlineVaultCount} files',
                  icon: Icons.download_done_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.0, color: colorScheme.primary),
        const SizedBox(height: 4.0),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10.5, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildSettingsToggles(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: colorScheme.primary,
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        isDark
                            ? 'Obsidian Studio Dark'
                            : 'Crisp Acoustic Light',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Switch(
                value: isDark,
                activeColor: colorScheme.primary,
                onChanged: (_) {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),
            ],
          ),
          const Divider(),
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.bug_report_outlined,
                color: colorScheme.secondary,
                size: 20.0,
              ),
              title: Text(
                'Recruiter Diagnostics Drawer',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Fault simulation, latency controls, speaker invites',
                style: TextStyle(
                  fontSize: 10.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _openDebugDrawer(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Strict Rule 3
        children: [
          Text(
            'Weekly Listening Hours (fl_chart)',
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity, // Strict Rule 3
            height: 140.0,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 8.0,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false, reservedSize: 0),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22.0,
                      getTitlesWidget: (val, _) => Text(
                        '${val.toInt()}h',
                        style: TextStyle(
                          fontSize: 9.0,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20.0,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Text(
                            days[idx],
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                    strokeWidth: 1.0,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(days.length, (i) {
                  final day = days[i];
                  final val = _weeklyHours[day] ?? 2.0;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: val,
                        color: i == 5 || i == 6
                            ? colorScheme.secondary
                            : colorScheme.primary,
                        width: 14.0,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4.0),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreDistribution(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acoustic Genre Distribution',
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10.0),
          ..._genreDist.entries.map((entry) {
            final pct = (entry.value / 40.0).clamp(0.05, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${entry.value} hrs',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  LinearProgressIndicator(
                    value: pct,
                    minHeight: 4.0,
                    borderRadius: BorderRadius.circular(2.0),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAppFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: GestureDetector(
        onLongPress: () {
          _openDebugDrawer(context);
          AppFeedback.showInfo(
            context,
            'Recruiter Debug Drawer activated by long-press.',
          );
        },
        child: Column(
          children: [
            Text(
              'EchoStream Acoustic Studio • Version ${AppConstants.appVersion}',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              'Long-press version to open Recruiter Diagnostics',
              style: TextStyle(fontSize: 9.5, color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
