// Get Started landing page shown before entering Moodora.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../providers/user_profile_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_gradients.dart';
import '../widgets/common_gradient_button.dart';
import 'create_profile_screen.dart';
import 'home_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  void _enterApp(BuildContext context) {
    final hasProfile = context.read<UserProfileProvider>().hasProfile;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            hasProfile ? const HomeScreen() : const CreateProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor:
          isLight ? AppColors.lightBackground : AppColors.deepBackground,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isLight
              ? AppGradients.lightPageBackground
              : AppGradients.pageBackground,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _MoodoraLogo(),
                    const SizedBox(height: 28),
                    Text(
                      'Welcome to Moodora',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Organize your tasks, track your focus, and understand your mood.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 34),
                    CommonGradientButton(
                      label: 'Get Started',
                      icon: Icons.arrow_forward_rounded,
                      width: 220,
                      onPressed: () => _enterApp(context),
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
}

class _MoodoraLogo extends StatelessWidget {
  const _MoodoraLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.tomato.withValues(alpha: 0.28),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          'assets/logo/moodora_icon.svg',
          fit: BoxFit.cover,
          semanticsLabel: 'Moodora logo',
        ),
      ),
    );
  }
}
