// Screen for switching between local profiles.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/focus_coach_provider.dart';
import '../providers/focus_map_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/task_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/common_gradient_button.dart';
import '../widgets/profile_card.dart';
import 'create_profile_screen.dart';

class SwitchProfileScreen extends StatelessWidget {
  const SwitchProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProfileProvider>();
    final profiles = provider.profiles;
    final activeId = provider.activeUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Switch Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ...profiles.map(
              (profile) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProfileCard(
                  profile: profile,
                  isActive: profile.id == activeId,
                  onTap: () => _switch(context, profile.id),
                  onDelete: profiles.length <= 1
                      ? null
                      : () => _delete(context, profile.id),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CommonGradientButton(
              label: 'Add new profile',
              icon: Icons.person_add_alt_1,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switch(BuildContext context, int? id) async {
    if (id == null) {
      return;
    }
    await context.read<UserProfileProvider>().switchProfile(id);
    if (!context.mounted) {
      return;
    }
    await _reloadProfileBoundProviders(context);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete(BuildContext context, int? id) async {
    if (id == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete profile?'),
        content: const Text('All linked local data will be deleted.'),
        actions: [
          CommonGradientButton(
            label: 'Cancel',
            primary: false,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CommonGradientButton(
            label: 'Delete',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<UserProfileProvider>().deleteProfile(id);
      if (context.mounted) {
        await _reloadProfileBoundProviders(context);
      }
    }
  }

  Future<void> _reloadProfileBoundProviders(BuildContext context) async {
    final userId = context.read<UserProfileProvider>().activeUserId;
    await Future.wait([
      context.read<SettingsProvider>().updateActiveUser(userId),
      context.read<TaskProvider>().updateActiveUser(userId),
      context.read<StatsProvider>().updateActiveUser(userId),
      context.read<MoodProvider>().updateActiveUser(userId),
      Future(() {
        context.read<FocusCoachProvider>().updateActiveUser(userId);
      }),
      context.read<FocusMapProvider>().updateActiveUser(userId),
    ]);
  }
}
