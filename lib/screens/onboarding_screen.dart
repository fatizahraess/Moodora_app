// First-launch onboarding for local profiles.
import 'package:flutter/material.dart';

import '../widgets/common_gradient_button.dart';
import 'create_profile_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🍅', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 18),
                  Text(
                    'Welcome to Moodora',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tasks, Pomodoro, mood tracking and focus insights in one local app.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  const _Benefit(
                    icon: Icons.checklist,
                    title: 'Organize your tasks',
                  ),
                  const _Benefit(
                    icon: Icons.timer_outlined,
                    title: 'Track your focus',
                  ),
                  const _Benefit(
                    icon: Icons.mood_outlined,
                    title: 'Understand your mood',
                  ),
                  const SizedBox(height: 28),
                  CommonGradientButton(
                    label: 'Create my profile',
                    icon: Icons.person_add_alt_1,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
