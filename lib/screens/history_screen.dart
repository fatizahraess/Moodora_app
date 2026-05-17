// History screen showing grouped Pomodoro sessions and weekly statistics.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/mood_dao.dart';
import '../database/session_dao.dart';
import '../models/mood_entry.dart';
import '../models/pomodoro_session.dart';
import '../providers/stats_provider.dart';
import '../providers/user_profile_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/date_formatter.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_history_card.dart';
import '../widgets/stat_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final SessionDao _sessionDao = SessionDao();
  final MoodDao _moodDao = MoodDao();
  late Future<Map<String, List<PomodoroSession>>> _sessionsFuture;
  late Future<Map<int, MoodEntry>> _moodsBySessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _sessionDao.getSessionsGroupedByDate();
    _moodsBySessionFuture = _loadMoodsBySession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StatsProvider>().loadStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final userId = context.watch<UserProfileProvider>().activeUserId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.showAppBar ? AppBar(title: const Text('History')) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient:
              Theme.of(context).extension<PremiumGradientTheme>()?.background,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _sessionsFuture = userId == null
                  ? Future.value(<String, List<PomodoroSession>>{})
                  : _sessionDao.getSessionsGroupedByDateByUserId(userId);
              _moodsBySessionFuture = _loadMoodsBySession();
            });
            await context.read<StatsProvider>().loadStats();
          },
          child: FutureBuilder<_HistoryData>(
            future: Future.wait<Object>([
              userId == null
                  ? Future.value(<String, List<PomodoroSession>>{})
                  : _sessionDao.getSessionsGroupedByDateByUserId(userId),
              _loadMoodsBySession(),
            ]).then(
              (values) => _HistoryData(
                sessionsByDate:
                    values[0] as Map<String, List<PomodoroSession>>,
                moodsBySession: values[1] as Map<int, MoodEntry>,
              ),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final grouped = snapshot.data?.sessionsByDate ?? {};
              final moodsBySession = snapshot.data?.moodsBySession ?? {};

              if (grouped.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: EmptyState(
                      icon: Icons.history,
                      title: 'No sessions yet',
                      description:
                          'Complete a focus session to build your history.',
                    ),
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 40,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 620),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (!widget.showAppBar) ...[
                                  const _PageTitle(
                                    title: 'History',
                                    subtitle:
                                        'Review your completed focus sessions',
                                  ),
                                  const SizedBox(height: 18),
                                ],
                                GridView.count(
                                  crossAxisCount:
                                      constraints.maxWidth > 560 ? 4 : 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio: 1.25,
                                  children: [
                                    StatCard(
                                      title: 'Today',
                                      value:
                                          stats.todayPomodoroCount.toString(),
                                      icon: Icons.today,
                                      color: AppConstants.primaryColor,
                                    ),
                                    StatCard(
                                      title: 'This week',
                                      value:
                                          stats.weeklyPomodoroCount.toString(),
                                      icon: Icons.calendar_view_week,
                                      color: AppConstants.secondaryColor,
                                    ),
                                    StatCard(
                                      title: 'Weekly minutes',
                                      value:
                                          stats.weeklyFocusMinutes.toString(),
                                      icon: Icons.trending_up,
                                      color: AppConstants.successColor,
                                    ),
                                    StatCard(
                                      title: 'Total sessions',
                                      value:
                                          stats.totalPomodoroCount.toString(),
                                      icon: Icons.all_inclusive,
                                      color: AppConstants.warningColor,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ...grouped.entries.map((entry) {
                                  final sessions = entry.value;
                                  final dayFocus = sessions
                                      .where(
                                        (session) => session.isWorkSession,
                                      )
                                      .fold<int>(
                                        0,
                                        (sum, session) =>
                                            sum + session.duration,
                                      );

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${DateFormatter.fullDate(DateTime.parse(entry.key))} · $dayFocus focus min',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: AppColors.lightText,
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        const SizedBox(height: 10),
                                        ...sessions.map(
                                          (session) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 10,
                                            ),
                                            child: SessionHistoryCard(
                                              session: session,
                                              moodLabel: _moodLabelForSession(
                                                moodsBySession[session.id],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<Map<int, MoodEntry>> _loadMoodsBySession() async {
    final userId = context.read<UserProfileProvider>().activeUserId;
    if (userId == null) {
      return {};
    }
    final entries = await _moodDao.getAllMoodEntriesByUserId(userId);
    return {
      for (final entry in entries)
        if (entry.sessionId != null) entry.sessionId!: entry,
    };
  }

  String? _moodLabelForSession(MoodEntry? entry) {
    if (entry == null) {
      return null;
    }
    if (entry.moodAfter.isNotEmpty) {
      return entry.moodAfter;
    }
    if (entry.moodBefore.isNotEmpty) {
      return entry.moodBefore;
    }
    return null;
  }
}

class _HistoryData {
  const _HistoryData({
    required this.sessionsByDate,
    required this.moodsBySession,
  });

  final Map<String, List<PomodoroSession>> sessionsByDate;
  final Map<int, MoodEntry> moodsBySession;
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
