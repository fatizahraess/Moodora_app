// Focus Mood screen for tracking mood, energy, stress, notes, history, and insights.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../providers/stats_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/app_gradients.dart';
import '../widgets/common_gradient_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/mood_history_card.dart';
import '../widgets/mood_insight_card.dart';
import '../widgets/mood_selector.dart';
import '../widgets/mood_summary_card.dart';
import '../theme/app_theme.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final stats = context.read<StatsProvider>();
      context.read<MoodProvider>().loadMoodData(
            todayFocusMinutes: stats.todayFocusMinutes,
            todayPomodoroCount: stats.todayPomodoroCount,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.showAppBar ? AppBar(title: const Text('Mood')) : null,
      body: Consumer<MoodProvider>(
        builder: (context, provider, child) {
          final error = provider.errorMessage;
          if (error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
              context.read<MoodProvider>().clearError();
            });
          }

          if (provider.isLoading && provider.moodEntries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            decoration: BoxDecoration(
              gradient: Theme.of(context)
                  .extension<PremiumGradientTheme>()
                  ?.background,
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                final stats = context.read<StatsProvider>();
                await context.read<MoodProvider>().loadMoodData(
                      todayFocusMinutes: stats.todayFocusMinutes,
                      todayPomodoroCount: stats.todayPomodoroCount,
                    );
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                children: [
                  const _MoodHeader(),
                  const SizedBox(height: 18),
                  CommonGradientButton(
                    label: 'Add mood',
                    icon: Icons.add_reaction_outlined,
                    onPressed: () => _showMoodSheet(context),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoodSummaryCard(
                        dominantMood: provider.dominantMood,
                        moodScore: provider.moodScore,
                        averageEnergy: provider.averageEnergy,
                        averageStress: provider.averageStress,
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle('Mood insights'),
                      const SizedBox(height: 10),
                      ...provider.insights.map(
                        (insight) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: MoodInsightCard(insight: insight),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle('Mood history'),
                      const SizedBox(height: 10),
                      if (provider.moodEntries.isEmpty)
                        const EmptyState(
                          icon: Icons.mood_bad_outlined,
                          title: 'No mood entries yet',
                          description:
                              'Add a mood entry manually or after a focus session.',
                        )
                      else
                        ...provider.moodEntries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MoodHistoryCard(moodEntry: entry),
                          ),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showMoodSheet(BuildContext context) async {
    final result = await showModalBottomSheet<_MoodFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _MoodFormSheet(),
    );
    if (result == null || !context.mounted) {
      return;
    }
    await context.read<MoodProvider>().addMoodEntry(
          MoodEntry(
            userId: 0,
            moodBefore: result.moodBefore,
            moodAfter: result.moodAfter,
            energyLevel: result.energyLevel,
            stressLevel: result.stressLevel,
            date: DateTime.now(),
            note: result.note,
          ),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood saved')),
      );
    }
  }
}

class _MoodHeader extends StatelessWidget {
  const _MoodHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightLine),
      ),
      child: Column(
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.timerAccent,
              boxShadow: [
                BoxShadow(
                  color: AppColors.coral.withValues(alpha: 0.32),
                  blurRadius: 34,
                ),
              ],
            ),
            child: const Center(
              child: Text('😊', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'How are you feeling?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track how your mood affects productivity',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MoodFormSheet extends StatefulWidget {
  const _MoodFormSheet();

  @override
  State<_MoodFormSheet> createState() => _MoodFormSheetState();
}

class _MoodFormSheetState extends State<_MoodFormSheet> {
  final TextEditingController _noteController = TextEditingController();
  String? _moodBefore;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MoodSelector(
              selectedMood: _moodBefore,
              onMoodSelected: (mood) => setState(() => _moodBefore = mood),
              title: 'Mood before',
            ),
            const SizedBox(height: 18),
            MoodSelector(
              selectedMood: _moodAfter,
              onMoodSelected: (mood) => setState(() => _moodAfter = mood),
              title: 'Mood after',
            ),
            const SizedBox(height: 18),
            _RatingSlider(
              label: 'Energy',
              value: _energyLevel,
              onChanged: (value) => setState(() => _energyLevel = value),
            ),
            _RatingSlider(
              label: 'Stress',
              value: _stressLevel,
              onChanged: (value) => setState(() => _stressLevel = value),
            ),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Note',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 16),
            CommonGradientButton(
              label: 'Save mood',
              icon: Icons.favorite,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if ((_moodBefore == null || _moodBefore!.isEmpty) &&
        (_moodAfter == null || _moodAfter!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one mood')),
      );
      return;
    }
    Navigator.of(context).pop(
      _MoodFormResult(
        moodBefore: _moodBefore ?? '',
        moodAfter: _moodAfter ?? '',
        energyLevel: _energyLevel,
        stressLevel: _stressLevel,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }
}

class _RatingSlider extends StatelessWidget {
  const _RatingSlider({
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

class _MoodFormResult {
  const _MoodFormResult({
    required this.moodBefore,
    required this.moodAfter,
    required this.energyLevel,
    required this.stressLevel,
    this.note,
  });

  final String moodBefore;
  final String moodAfter;
  final int energyLevel;
  final int stressLevel;
  final String? note;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
    );
  }
}
