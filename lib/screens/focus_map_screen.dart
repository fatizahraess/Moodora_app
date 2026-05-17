// Focus Map screen that visualizes how focus time is distributed across tasks and priorities.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/focus_map_provider.dart';
import '../providers/pomodoro_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/app_gradients.dart';
import '../widgets/empty_state.dart';
import '../widgets/focus_distribution_card.dart';
import '../widgets/insight_card.dart';
import '../widgets/neglected_task_card.dart';
import '../widgets/weekly_focus_heatmap.dart';
import '../theme/app_theme.dart';

class FocusMapScreen extends StatefulWidget {
  const FocusMapScreen({
    super.key,
    this.showAppBar = true,
    this.onStartFocus,
  });

  final bool showAppBar;
  final VoidCallback? onStartFocus;

  @override
  State<FocusMapScreen> createState() => _FocusMapScreenState();
}

class _FocusMapScreenState extends State<FocusMapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FocusMapProvider>().loadFocusMap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.showAppBar ? AppBar(title: const Text('Focus Map')) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<PremiumGradientTheme>()?.background,
        ),
        child: Consumer<FocusMapProvider>(
        builder: (context, provider, child) {
          final error = provider.errorMessage;
          if (error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
              context.read<FocusMapProvider>().clearError();
            });
          }

          if (provider.isLoading && provider.focusByTask.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: context.read<FocusMapProvider>().loadFocusMap,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const _FocusMapHeader(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: provider.focusByTask.isEmpty
                      ? const EmptyState(
                          icon: Icons.map_outlined,
                          title: 'No focus map yet',
                          description:
                              'Complete a work session to see where your focus time goes.',
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FocusDistributionCard(
                              title: 'Focus by Task',
                              items: provider.focusByTask,
                            ),
                            const SizedBox(height: 16),
                            FocusDistributionCard(
                              title: 'Focus by Priority',
                              items: provider.focusByPriority,
                            ),
                            const SizedBox(height: 16),
                            WeeklyFocusHeatmap(
                              weeklyFocusMinutes: provider.weeklyFocusMinutes,
                            ),
                            const SizedBox(height: 20),
                            _SectionTitle(
                              title: 'Neglected Tasks',
                              subtitle: provider.neglectedTasks.isEmpty
                                  ? 'No important task is being ignored.'
                                  : '${provider.neglectedTasks.length} tasks need attention',
                            ),
                            const SizedBox(height: 10),
                            if (provider.neglectedTasks.isEmpty)
                              const EmptyState(
                                icon: Icons.verified_outlined,
                                title: 'Good alignment',
                                description:
                                    'Your important active tasks have received attention.',
                              )
                            else
                              ...provider.neglectedTasks.map(
                                (task) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: NeglectedTaskCard(
                                    task: task,
                                    onStartFocus: () {
                                      context
                                          .read<PomodoroProvider>()
                                          .selectTask(task.id);
                                      context
                                          .read<PomodoroProvider>()
                                          .setMode(PomodoroMode.work);
                                      widget.onStartFocus?.call();
                                    },
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            const _SectionTitle(
                              title: 'Insights',
                              subtitle: 'What your focus pattern suggests',
                            ),
                            const SizedBox(height: 10),
                            ...provider.insights.map(
                              (insight) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InsightCard(insight: insight),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }
}

class _FocusMapHeader extends StatelessWidget {
  const _FocusMapHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 22,
        20,
        28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.tomato, AppColors.tomatoSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Focus Map',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Understand where your focus time goes',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, textAlign: TextAlign.center),
      ],
    );
  }
}
