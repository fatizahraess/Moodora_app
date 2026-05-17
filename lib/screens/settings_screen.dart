// Settings screen for timer durations, daily goal, notifications, and theme mode.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../providers/settings_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_gradients.dart';
import '../widgets/common_gradient_button.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: showAppBar ? AppBar(title: const Text('Settings')) : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).extension<PremiumGradientTheme>()?.background,
        ),
        child: Consumer<SettingsProvider>(
        builder: (context, provider, child) {
          final settings = provider.settings;
          final error = provider.errorMessage;
          if (error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
              context.read<SettingsProvider>().clearError();
            });
          }

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (!showAppBar) ...[
                const _PageTitle(
                  title: 'Settings',
                  subtitle: 'Tune your tomato timer',
                ),
                const SizedBox(height: 18),
              ],
              CommonGradientButton(
                label: 'Profile',
                icon: Icons.person_outline,
                primary: false,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _NumberSettingTile(
                title: 'Work duration',
                subtitle: '${settings.workDuration} minutes',
                value: settings.workDuration,
                min: 1,
                max: 120,
                onChanged: (value) => provider.updateSettings(
                  settings.copyWith(workDuration: value),
                ),
              ),
              _NumberSettingTile(
                title: 'Short break duration',
                subtitle: '${settings.shortBreakDuration} minutes',
                value: settings.shortBreakDuration,
                min: 1,
                max: 60,
                onChanged: (value) => provider.updateSettings(
                  settings.copyWith(shortBreakDuration: value),
                ),
              ),
              _NumberSettingTile(
                title: 'Long break duration',
                subtitle: '${settings.longBreakDuration} minutes',
                value: settings.longBreakDuration,
                min: 1,
                max: 90,
                onChanged: (value) => provider.updateSettings(
                  settings.copyWith(longBreakDuration: value),
                ),
              ),
              _NumberSettingTile(
                title: 'Daily Pomodoro goal',
                subtitle: '${settings.dailyPomodoroGoal} sessions',
                value: settings.dailyPomodoroGoal,
                min: 1,
                max: 16,
                onChanged: (value) => provider.updateSettings(
                  settings.copyWith(dailyPomodoroGoal: value),
                ),
              ),
              Card(
                child: SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Notify me when a session finishes'),
                  value: settings.notificationsEnabled,
                  onChanged: (value) => provider.updateSettings(
                    settings.copyWith(notificationsEnabled: value),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: settings.themeMode,
                    decoration: const InputDecoration(
                      labelText: 'Theme',
                      prefixIcon: Icon(Icons.contrast),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'system', child: Text('System')),
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'dark', child: Text('Dark')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        provider.updateSettings(
                          settings.copyWith(themeMode: value),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CommonGradientButton(
                onPressed: () async {
                  await provider.resetSettings();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings reset')),
                    );
                  }
                },
                icon: Icons.restore,
                label: 'Reset settings',
                primary: false,
              ),
            ],
          );
        },
        ),
      ),
    );
  }
}

class _NumberSettingTile extends StatelessWidget {
  const _NumberSettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              IconButton(
                onPressed: value > min ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: value < max ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
