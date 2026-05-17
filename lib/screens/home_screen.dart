// Dashboard screen with daily progress, quick focus, stats, and navigation.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/focus_coach_provider.dart';
import '../providers/focus_map_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/date_formatter.dart';
import '../utils/app_gradients.dart';
import '../widgets/common_gradient_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/focus_recommendation_card.dart';
import '../widgets/focus_score_card.dart';
import '../widgets/insight_card.dart';
import '../widgets/mood_insight_card.dart';
import '../widgets/mood_summary_card.dart';
import '../widgets/progress_summary_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/task_card.dart';
import '../theme/app_theme.dart';
import 'focus_map_screen.dart';
import 'history_screen.dart';
import 'mood_screen.dart';
import 'settings_screen.dart';
import 'task_screen.dart';
import 'timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _DashboardView(onNavigate: _openIndex),
      const TaskScreen(showAppBar: false),
      TimerScreen(showAppBar: false, onOpenSettings: () => _openIndex(6)),
      const MoodScreen(showAppBar: false),
      FocusMapScreen(showAppBar: false, onStartFocus: () => _openIndex(2)),
      const HistoryScreen(showAppBar: false),
      const SettingsScreen(showAppBar: false),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.mood_outlined),
            selectedIcon: Icon(Icons.mood),
            label: 'Mood',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _openIndex(int index) {
    setState(() => _selectedIndex = index);
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<TaskProvider>().loadTasks();
      context.read<StatsProvider>().loadStats();
      context.read<FocusCoachProvider>().loadCoach();
      context.read<FocusMapProvider>().loadFocusMap();
      final stats = context.read<StatsProvider>();
      context.read<MoodProvider>().loadMoodData(
            todayFocusMinutes: stats.todayFocusMinutes,
            todayPomodoroCount: stats.todayPomodoroCount,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final statsProvider = context.watch<StatsProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final focusCoachProvider = context.watch<FocusCoachProvider>();
    final focusMapProvider = context.watch<FocusMapProvider>();
    final moodProvider = context.watch<MoodProvider>();
    final activeTasks = taskProvider.activeTasks.take(3).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<TaskProvider>().loadTasks(),
            context.read<StatsProvider>().loadStats(),
            context.read<FocusCoachProvider>().loadCoach(),
            context.read<FocusMapProvider>().loadFocusMap(),
            context.read<MoodProvider>().loadMoodData(
                  todayFocusMinutes: statsProvider.todayFocusMinutes,
                  todayPomodoroCount: statsProvider.todayPomodoroCount,
                ),
          ]);
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: Theme.of(context)
                .extension<PremiumGradientTheme>()
                ?.background,
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _GradientHeader(
                title: 'Welcome back',
                subtitle: DateFormatter.fullDate(DateTime.now()),
                onHistory: () => widget.onNavigate(5),
                onSettings: () => widget.onNavigate(6),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProgressSummaryCard(
                      completed: statsProvider.todayPomodoroCount,
                      goal: settingsProvider.settings.dailyPomodoroGoal,
                    ),
                    const SizedBox(height: 20),
                    _SectionHeader(
                      title: 'Focus Coach',
                      actionLabel: 'Refresh',
                      onAction: () =>
                          context.read<FocusCoachProvider>().loadCoach(),
                    ),
                    const SizedBox(height: 12),
                    FocusScoreCard(
                      score: focusCoachProvider.focusScore,
                      label: focusCoachProvider.focusScoreLabel,
                    ),
                    const SizedBox(height: 12),
                    FocusRecommendationCard(
                      recommendation: focusCoachProvider.recommendation,
                      onStart: focusCoachProvider.recommendation == null
                          ? null
                          : () {
                              context.read<PomodoroProvider>().selectTask(
                                    focusCoachProvider.recommendation!.task.id,
                                  );
                            context
                                .read<PomodoroProvider>()
                                .setMode(PomodoroMode.work);
                            widget.onNavigate(2);
                          },
                    ),
                    const SizedBox(height: 12),
                    ...focusCoachProvider.insights.take(3).map(
                          (insight) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InsightCard(insight: insight),
                          ),
                        ),
                    const SizedBox(height: 16),
                    _FocusMapSummaryCard(
                      topFocusTask: focusMapProvider.focusByTask.isEmpty
                          ? 'No focus data yet'
                          : focusMapProvider.focusByTask.first.title,
                      neglectedTaskCount: focusMapProvider.neglectedTasks.length,
                      weeklyFocusMinutes: focusMapProvider.weeklyTotalFocusMinutes,
                    onOpen: () => widget.onNavigate(4),
                    ),
                    const SizedBox(height: 16),
                    _SectionHeader(
                      title: 'Focus Mood',
                      actionLabel: 'Open',
                      onAction: () {
                        Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MoodScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    MoodSummaryCard(
                      dominantMood: moodProvider.dominantMood,
                      moodScore: moodProvider.moodScore,
                      averageEnergy: moodProvider.averageEnergy,
                      averageStress: moodProvider.averageStress,
                      compact: true,
                    ),
                    const SizedBox(height: 12),
                    ...moodProvider.insights.take(2).map(
                          (insight) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: MoodInsightCard(insight: insight),
                          ),
                        ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount:
                          MediaQuery.sizeOf(context).width > 650 ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.15,
                      children: [
                        StatCard(
                          title: 'Tasks done today',
                          value: statsProvider.completedTasksToday.toString(),
                          icon: Icons.task_alt,
                          color: AppConstants.successColor,
                        ),
                        StatCard(
                          title: 'Sessions today',
                          value: statsProvider.todayPomodoroCount.toString(),
                          icon: Icons.local_fire_department_outlined,
                          color: AppConstants.primaryColor,
                        ),
                        StatCard(
                          title: 'Focus minutes',
                          value: statsProvider.todayFocusMinutes.toString(),
                          icon: Icons.trending_up,
                          color: AppConstants.secondaryColor,
                        ),
                        StatCard(
                          title: 'Current streak',
                          value: '${statsProvider.currentStreak}d',
                          icon: Icons.bolt,
                          color: AppConstants.warningColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _QuickStartCard(onStart: () {
                    context.read<PomodoroProvider>().setMode(PomodoroMode.work);
                    widget.onNavigate(2);
                    }),
                    const SizedBox(height: 20),
                    _SectionHeader(
                      title: 'Recent active tasks',
                      actionLabel: 'View all',
                    onAction: () => widget.onNavigate(1),
                    ),
                    const SizedBox(height: 12),
                    if (activeTasks.isEmpty)
                      EmptyState(
                        icon: Icons.check_circle_outline,
                        title: 'No active tasks',
                        description:
                            'Create a task and link it to a focus session.',
                        actionLabel: 'Add task',
                        onAction: () => widget.onNavigate(1),
                      )
                    else
                      ...activeTasks.map(
                        (Task task) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskCard(
                            task: task,
                            onToggleCompleted: () async {
                              await context
                                  .read<TaskProvider>()
                                  .toggleTaskCompletion(task);
                              if (context.mounted) {
                                context.read<StatsProvider>().loadStats();
                                context.read<FocusCoachProvider>().loadCoach();
                                context.read<FocusMapProvider>().loadFocusMap();
                              }
                            },
                            onEdit: () => widget.onNavigate(1),
                            onDelete: () => widget.onNavigate(1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({
    required this.title,
    required this.subtitle,
    required this.onHistory,
    required this.onSettings,
  });

  final String title;
  final String subtitle;
  final VoidCallback onHistory;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 20,
        20,
        30,
      ),
      decoration: const BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Moodora',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              IconButton(
                tooltip: 'History',
                onPressed: onHistory,
                color: Colors.white,
                icon: const Icon(Icons.history),
              ),
              IconButton(
                tooltip: 'Settings',
                onPressed: onSettings,
                color: Colors.white,
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.textWhite),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  const _QuickStartCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Start Focus',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Jump into a work session with your current settings.'),
                ],
              ),
            ),
            IconButton.filled(
              onPressed: onStart,
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusMapSummaryCard extends StatelessWidget {
  const _FocusMapSummaryCard({
    required this.topFocusTask,
    required this.neglectedTaskCount,
    required this.weeklyFocusMinutes,
    required this.onOpen,
  });

  final String topFocusTask;
  final int neglectedTaskCount;
  final int weeklyFocusMinutes;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Focus Map',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                CommonGradientButton(
                  label: 'Open',
                  primary: false,
                  onPressed: onOpen,
                  width: 96,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _SummaryLine(label: 'Top focus task', value: topFocusTask),
            _SummaryLine(
              label: 'Neglected tasks',
              value: neglectedTaskCount.toString(),
            ),
            _SummaryLine(
              label: 'Weekly focus',
              value: '$weeklyFocusMinutes min',
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        CommonGradientButton(
          label: actionLabel,
          primary: false,
          onPressed: onAction,
          width: 112,
        ),
      ],
    );
  }
}
