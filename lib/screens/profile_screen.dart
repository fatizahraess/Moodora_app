// Screen for viewing, editing, switching, and deleting the active local profile.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/stats_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/avatar_selector.dart';
import '../widgets/common_gradient_button.dart';
import 'onboarding_screen.dart';
import 'switch_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  String _avatarEmoji = '🙂';
  int _dailyGoal = 4;
  int _workDuration = 25;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileProvider>().activeProfile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _avatarEmoji = profile?.avatarEmoji ?? '🙂';
    _dailyGoal = profile?.dailyPomodoroGoal ?? 4;
    _workDuration = profile?.preferredWorkDuration ?? 25;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().activeProfile;
    final stats = context.watch<StatsProvider>();

    if (profile == null) {
      return const OnboardingScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      profile.avatarEmoji,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 56),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 16),
                    _StatsRow(stats: stats),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Enter your name.'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration:
                          const InputDecoration(labelText: 'Email optional'),
                    ),
                    const SizedBox(height: 18),
                    AvatarSelector(
                      selectedAvatar: _avatarEmoji,
                      onAvatarSelected: (avatar) {
                        setState(() => _avatarEmoji = avatar);
                      },
                    ),
                    const SizedBox(height: 18),
                    _StepperTile(
                      title: 'Daily goal',
                      value: _dailyGoal,
                      min: 1,
                      max: 12,
                      onChanged: (value) => setState(() => _dailyGoal = value),
                    ),
                    _StepperTile(
                      title: 'Work duration',
                      value: _workDuration,
                      min: 5,
                      max: 90,
                      suffix: ' min',
                      onChanged: (value) =>
                          setState(() => _workDuration = value),
                    ),
                    const SizedBox(height: 16),
                    CommonGradientButton(
                      label: 'Save profile',
                      icon: Icons.save,
                      onPressed: () => _save(profile),
                    ),
                    const SizedBox(height: 12),
                    CommonGradientButton(
                      label: 'Switch Profile',
                      icon: Icons.switch_account,
                      primary: false,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SwitchProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    CommonGradientButton(
                      label: 'Delete Profile',
                      icon: Icons.delete_outline,
                      primary: false,
                      onPressed: () => _delete(profile),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(UserProfile profile) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await context.read<UserProfileProvider>().updateProfile(
          profile.copyWith(
            name: _nameController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            clearEmail: _emailController.text.trim().isEmpty,
            avatarEmoji: _avatarEmoji,
            dailyPomodoroGoal: _dailyGoal,
            preferredWorkDuration: _workDuration,
          ),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    }
  }

  Future<void> _delete(UserProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete profile?'),
        content: Text('This removes ${profile.name} and all linked data.'),
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
    if (confirmed != true || profile.id == null || !mounted) {
      return;
    }
    await context.read<UserProfileProvider>().deleteProfile(profile.id!);
    if (!mounted) {
      return;
    }
    if (!context.read<UserProfileProvider>().hasProfile) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (_) => false,
      );
    } else {
      Navigator.of(context).pop();
    }
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final StatsProvider stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatChip(label: 'Sessions', value: '${stats.totalPomodoroCount}')),
        const SizedBox(width: 10),
        Expanded(child: _StatChip(label: 'Streak', value: '${stats.currentStreak}d')),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.suffix = '',
  });

  final String title;
  final int value;
  final int min;
  final int max;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            Text('$value$suffix'),
            IconButton(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
