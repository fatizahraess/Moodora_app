// Reusable premium mood selector with colored chips and expressive mood labels.
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_gradients.dart';

class MoodSelector extends StatelessWidget {
  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    required this.title,
  });

  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;
  final String title;

  static const List<String> moods = [
    'motivated',
    'calm',
    'neutral',
    'tired',
    'stressed',
    'frustrated',
    'happy',
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isLight ? AppColors.lightText : AppColors.textWhite,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: moods.map((mood) {
            final selected = selectedMood == mood;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                gradient: selected ? AppGradients.cta : null,
                color: selected
                    ? null
                    : isLight
                        ? AppColors.lightSurfaceLavender
                        : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isLight ? AppColors.lightLine : AppColors.subtleLine,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.coral.withValues(alpha: 0.24),
                          blurRadius: 18,
                        ),
                      ]
                    : null,
              ),
              child: ChoiceChip(
                label: Text('${emojiForMood(mood)} ${labelForMood(mood)}'),
                selected: selected,
                showCheckmark: false,
                backgroundColor: Colors.transparent,
                selectedColor: Colors.transparent,
                side: BorderSide.none,
                labelStyle: TextStyle(
                  color: selected
                      ? AppColors.textWhite
                      : isLight
                          ? AppColors.lightText
                          : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
                onSelected: (_) => onMoodSelected(mood),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static String labelForMood(String mood) {
    return switch (mood) {
      'motivated' => 'Motivated',
      'calm' => 'Calm',
      'neutral' => 'Neutral',
      'tired' => 'Tired',
      'stressed' => 'Stressed',
      'frustrated' => 'Frustrated',
      'happy' => 'Happy',
      _ => 'Mood',
    };
  }

  static String emojiForMood(String mood) {
    return switch (mood) {
      'motivated' => '🚀',
      'calm' => '😌',
      'neutral' => '😐',
      'tired' => '😴',
      'stressed' => '😣',
      'frustrated' => '😤',
      'happy' => '😊',
      _ => '🙂',
    };
  }
}
