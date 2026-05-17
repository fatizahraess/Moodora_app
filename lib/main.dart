// Entry point that wires profile-scoped providers, settings-driven theme, and routing.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/focus_coach_provider.dart';
import 'providers/focus_map_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/pomodoro_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/task_provider.dart';
import 'providers/user_profile_provider.dart';
import 'screens/get_started_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FocusFlowAppRoot());
}

class FocusFlowAppRoot extends StatelessWidget {
  const FocusFlowAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProfileProvider()..loadProfiles(),
        ),
        ChangeNotifierProxyProvider<UserProfileProvider, SettingsProvider>(
          create: (_) => SettingsProvider(),
          update: (_, profileProvider, settingsProvider) {
            final provider = settingsProvider ?? SettingsProvider();
            provider.updateActiveUser(profileProvider.activeUserId);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<UserProfileProvider, TaskProvider>(
          create: (_) => TaskProvider(),
          update: (_, profileProvider, taskProvider) {
            final provider = taskProvider ?? TaskProvider();
            provider.updateActiveUser(profileProvider.activeUserId);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<UserProfileProvider, StatsProvider>(
          create: (_) => StatsProvider(),
          update: (_, profileProvider, statsProvider) {
            final provider = statsProvider ?? StatsProvider();
            provider.updateActiveUser(profileProvider.activeUserId);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider2<UserProfileProvider, SettingsProvider,
            FocusCoachProvider>(
          create: (_) => FocusCoachProvider(),
          update: (_, profileProvider, settingsProvider, focusCoachProvider) {
            final provider = focusCoachProvider ?? FocusCoachProvider();
            provider.updateActiveUser(profileProvider.activeUserId);
            provider.updateSettings(settingsProvider.settings);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<UserProfileProvider, FocusMapProvider>(
          create: (_) => FocusMapProvider(),
          update: (_, profileProvider, focusMapProvider) {
            final provider = focusMapProvider ?? FocusMapProvider();
            provider.updateActiveUser(profileProvider.activeUserId);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<UserProfileProvider, MoodProvider>(
          create: (_) => MoodProvider(),
          update: (_, profileProvider, moodProvider) {
            final provider = moodProvider ?? MoodProvider();
            provider.updateActiveUser(profileProvider.activeUserId);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider4<
            UserProfileProvider,
            SettingsProvider,
            FocusCoachProvider,
            FocusMapProvider,
            PomodoroProvider>(
          create: (_) => PomodoroProvider(),
          update: (
            _,
            profileProvider,
            settingsProvider,
            focusCoachProvider,
            focusMapProvider,
            pomodoroProvider,
          ) {
            final provider = pomodoroProvider ?? PomodoroProvider();
            provider.updateActiveUser(profileProvider.activeUserId);
            provider.updateSettings(settingsProvider.settings);
            provider.onSessionCompleted = () async {
              await Future.wait([
                focusCoachProvider.loadCoach(),
                focusMapProvider.loadFocusMap(),
              ]);
            };
            return provider;
          },
        ),
      ],
      child: const FocusFlowApp(),
    );
  }
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final profileProvider = context.watch<UserProfileProvider>();

    return MaterialApp(
      title: 'Moodora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.materialThemeMode,
      home: profileProvider.isLoading
          ? const _BootstrapScreen()
          : const GetStartedScreen(),
    );
  }
}

class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
