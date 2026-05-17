// Focus timer screen with task selection, chips, controls, and auto-save sessions.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mood_entry.dart';
import '../models/task.dart';
import '../providers/mood_provider.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/circular_timer.dart';
import '../widgets/common_glass_card.dart';
import '../widgets/common_gradient_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/mood_selector.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key, this.showAppBar = true, this.onOpenSettings});

  final bool showAppBar;
  final VoidCallback? onOpenSettings;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final Set<int> _handledSessionIds = {};

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final points = stats.totalPomodoroCount * 10;

    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: const Text('Timer')) : null,
      body: Consumer2<PomodoroProvider, TaskProvider>(
        builder: (context, pomodoroProvider, taskProvider, child) {
          final completedSessionId = pomodoroProvider.lastCompletedSessionId;
          if (completedSessionId != null &&
              !_handledSessionIds.contains(completedSessionId)) {
            _handledSessionIds.add(completedSessionId);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showMoodAfterSessionSheet(context, pomodoroProvider);
              }
            });
          }

          final error = pomodoroProvider.errorMessage;
          if (error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
              context.read<PomodoroProvider>().clearError();
            });
          }

          return Container(
            decoration: BoxDecoration(
              gradient: Theme.of(context)
                  .extension<PremiumGradientTheme>()
                  ?.background,
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
                children: [
                  const _CenteredPageTitle(
                    title: 'Pomodoro',
                    subtitle: 'Focus with your tomato timer',
                  ),
                  const SizedBox(height: 18),
                  Center(child: _ModeChips(provider: pomodoroProvider)),
                  const SizedBox(height: 26),
                  _PointsBadge(points: points),
                  const SizedBox(height: 8),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: CircularTimer(
                        remainingSeconds: pomodoroProvider.remainingSeconds,
                        totalSeconds: pomodoroProvider.totalSeconds,
                        progress: pomodoroProvider.progress,
                        label: pomodoroProvider.mode.label,
                        isRunning: pomodoroProvider.isRunning,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _TimerControls(
                    provider: pomodoroProvider,
                    onSettings: () => _openSettings(context),
                  ),
                  const SizedBox(height: 18),
                  _TaskSelector(
                    tasks: taskProvider.activeTasks,
                    selectedTaskId: pomodoroProvider.selectedTaskId,
                    onChanged: context.read<PomodoroProvider>().selectTask,
                  ),
                  const SizedBox(height: 18),
                  _TimerMeta(provider: pomodoroProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openSettings(BuildContext context) {
    if (widget.onOpenSettings != null) {
      widget.onOpenSettings!.call();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _showMoodAfterSessionSheet(
    BuildContext context,
    PomodoroProvider pomodoroProvider,
  ) async {
    final result = await showModalBottomSheet<_MoodAfterResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _MoodAfterSessionSheet(),
    );
    if (result == null || !context.mounted) {
      return;
    }

    await context.read<MoodProvider>().addMoodEntry(
          MoodEntry(
            userId: 0,
            sessionId: pomodoroProvider.lastCompletedSessionId,
            taskId: pomodoroProvider.lastSelectedTaskId,
            moodAfter: result.moodAfter,
            energyLevel: result.energyLevel,
            stressLevel: result.stressLevel,
            date: DateTime.now(),
            note: result.note,
          ),
        );

    if (context.mounted) {
      final stats = context.read<StatsProvider>();
      await context.read<MoodProvider>().loadMoodData(
            todayFocusMinutes: stats.todayFocusMinutes,
            todayPomodoroCount: stats.todayPomodoroCount,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood saved')),
      );
    }
  }
}

class _CenteredPageTitle extends StatelessWidget {
  const _CenteredPageTitle({
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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

class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurface : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLight ? AppColors.lightLine : AppColors.subtleLine,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.tomato.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          'Points $points',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isLight ? AppColors.ink : Colors.white,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _MoodAfterSessionSheet extends StatefulWidget {
  const _MoodAfterSessionSheet();

  @override
  State<_MoodAfterSessionSheet> createState() => _MoodAfterSessionSheetState();
}

class _MoodAfterSessionSheetState extends State<_MoodAfterSessionSheet> {
  final TextEditingController _noteController = TextEditingController();
  String? _moodAfter;
  int _energyLevel = 3;
  int _stressLevel = 3;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How do you feel after this session?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 16),
            MoodSelector(
              selectedMood: _moodAfter,
              onMoodSelected: (mood) => setState(() => _moodAfter = mood),
              title: 'Mood after',
            ),
            const SizedBox(height: 16),
            _MoodRating(
              label: 'Energy',
              value: _energyLevel,
              onChanged: (value) => setState(() => _energyLevel = value),
            ),
            _MoodRating(
              label: 'Stress',
              value: _stressLevel,
              onChanged: (value) => setState(() => _stressLevel = value),
            ),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Optional note',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CommonGradientButton(
                    label: 'Skip',
                    primary: false,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CommonGradientButton(
                    label: 'Save mood',
                    icon: Icons.save,
                    onPressed: _moodAfter == null
                        ? null
                        : () => Navigator.of(context).pop(
                              _MoodAfterResult(
                                moodAfter: _moodAfter!,
                                energyLevel: _energyLevel,
                                stressLevel: _stressLevel,
                                note: _noteController.text.trim().isEmpty
                                    ? null
                                    : _noteController.text.trim(),
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodRating extends StatelessWidget {
  const _MoodRating({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value/5'),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: value.toString(),
          onChanged: (newValue) => onChanged(newValue.round()),
        ),
      ],
    );
  }
}

class _MoodAfterResult {
  const _MoodAfterResult({
    required this.moodAfter,
    required this.energyLevel,
    required this.stressLevel,
    this.note,
  });

  final String moodAfter;
  final int energyLevel;
  final int stressLevel;
  final String? note;
}

class _ModeChips extends StatelessWidget {
  const _ModeChips({required this.provider});

  final PomodoroProvider provider;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: PomodoroMode.values.map((mode) {
        final selected = provider.mode == mode;
        return CommonGradientButton(
          label: mode.label.toUpperCase(),
          width: 146,
          primary: selected,
          onPressed: provider.isRunning ? null : () => provider.setMode(mode),
        );
      }).toList(),
    );
  }
}

class _TaskSelector extends StatelessWidget {
  const _TaskSelector({
    required this.tasks,
    required this.selectedTaskId,
    required this.onChanged,
  });

  final List<Task> tasks;
  final int? selectedTaskId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.task_alt,
        title: 'No active task selected',
        description: 'You can still run a session, or create tasks first.',
      );
    }

    final value = selectedTaskId != null &&
            tasks.any((task) => task.id == selectedTaskId)
        ? selectedTaskId
        : 0;

    return CommonGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<int>(
        value: value,
        dropdownColor: AppColors.surface,
        decoration: const InputDecoration(
          labelText: 'Focus task',
          prefixIcon: Icon(Icons.link),
        ),
        items: [
          const DropdownMenuItem(value: 0, child: Text('No linked task')),
          ...tasks.map(
            (task) => DropdownMenuItem(
              value: task.id ?? 0,
              child: Text(task.title),
            ),
          ),
        ],
        onChanged: (value) => onChanged(value == 0 ? null : value),
      ),
    );
  }
}

class _TimerMeta extends StatelessWidget {
  const _TimerMeta({required this.provider});

  final PomodoroProvider provider;

  @override
  Widget build(BuildContext context) {
    return CommonGlassCard(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Expanded(
              child: _MetaItem(
                label: 'Current',
                value: provider.mode.label,
                icon: Icons.radio_button_checked,
              ),
            ),
            Expanded(
              child: _MetaItem(
                label: 'Next',
                value: provider.nextSessionLabel,
                icon: Icons.skip_next,
              ),
            ),
            Expanded(
              child: _MetaItem(
                label: 'Sessions',
                value: provider.sessionCount.toString(),
                icon: Icons.local_fire_department,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.softLavender),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _TimerControls extends StatelessWidget {
  const _TimerControls({
    required this.provider,
    required this.onSettings,
  });

  final PomodoroProvider provider;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CommonGradientButton(
                onPressed: provider.startOrPause,
                label: provider.isRunning ? 'Pause' : 'Start',
                icon: provider.isRunning ? Icons.pause : Icons.play_arrow,
                width: double.infinity,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CommonGradientButton(
                onPressed: onSettings,
                label: 'Settings',
                icon: Icons.settings_outlined,
                primary: false,
                width: double.infinity,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              tooltip: 'Reset',
              onPressed: provider.reset,
              icon: const Icon(Icons.restart_alt),
            ),
            const SizedBox(width: 12),
            IconButton.filledTonal(
              tooltip: 'Skip',
              onPressed: () async {
                await provider.skip();
                if (context.mounted) {
                  context.read<StatsProvider>().loadStats();
                }
              },
              icon: const Icon(Icons.skip_next),
            ),
          ],
        ),
      ],
    );
  }
}
