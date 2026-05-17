// Tomato Pomodoro theme shared across the app.
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_gradients.dart';
import '../utils/app_spacing.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        background: AppColors.deepBackground,
        surface: AppColors.surface,
        surfaceAlt: AppColors.surfaceDark,
        onSurface: AppColors.textWhite,
        secondaryText: AppColors.textSecondary,
        mutedText: AppColors.textMuted,
        line: AppColors.subtleLine,
        navigationBackground: AppColors.surfaceDark.withValues(alpha: 0.96),
        pageGradient: AppGradients.pageBackground,
      );

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        surfaceAlt: AppColors.lightSurfaceLavender,
        onSurface: AppColors.lightText,
        secondaryText: AppColors.lightTextMuted,
        mutedText: AppColors.lightTextMuted,
        line: AppColors.lightLine,
        navigationBackground: Colors.white.withValues(alpha: 0.96),
        pageGradient: AppGradients.lightPageBackground,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceAlt,
    required Color onSurface,
    required Color secondaryText,
    required Color mutedText,
    required Color line,
    required Color navigationBackground,
    required Gradient pageGradient,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      brightness: brightness,
      primary: AppColors.primaryPurple,
      secondary: AppColors.coral,
      surface: surface,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      canvasColor: background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w900),
        displayMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w900),
        headlineLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w900),
        headlineMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w900),
        headlineSmall: TextStyle(color: onSurface, fontWeight: FontWeight.w900),
        titleLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w800),
        titleSmall: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: onSurface),
        bodyMedium: TextStyle(color: onSurface),
        bodySmall: TextStyle(color: mutedText),
        labelLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w800),
        labelMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
        labelSmall: TextStyle(color: mutedText, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: BorderSide(color: line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        labelStyle: TextStyle(color: mutedText),
        hintStyle: TextStyle(color: mutedText),
        prefixIconColor: AppColors.primaryPurple,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primaryPurple),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.tomato,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: AppColors.tomato,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: brightness == Brightness.light
              ? AppColors.tomato
              : AppColors.tomatoSoft,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              brightness == Brightness.light ? AppColors.tomato : onSurface,
          side: BorderSide(color: line),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brightness == Brightness.light
            ? AppColors.tomato
            : AppColors.tomatoSoft,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        selectedColor: brightness == Brightness.light
            ? AppColors.primaryPurple
            : AppColors.coral,
        disabledColor: surfaceAlt.withValues(alpha: 0.6),
        labelStyle: TextStyle(color: secondaryText, fontWeight: FontWeight.w700),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
        side: BorderSide(color: line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: navigationBackground,
        indicatorColor: AppColors.tomato.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.tomato
                : mutedText,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.tomato
                : mutedText,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: mutedText,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.light
            ? AppColors.lightText
            : AppColors.surfaceDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
      ),
      extensions: [
        PremiumGradientTheme(background: pageGradient),
      ],
    );
  }
}

class PremiumGradientTheme extends ThemeExtension<PremiumGradientTheme> {
  const PremiumGradientTheme({required this.background});

  final Gradient background;

  @override
  ThemeExtension<PremiumGradientTheme> copyWith({Gradient? background}) {
    return PremiumGradientTheme(background: background ?? this.background);
  }

  @override
  ThemeExtension<PremiumGradientTheme> lerp(
    covariant ThemeExtension<PremiumGradientTheme>? other,
    double t,
  ) {
    if (other is! PremiumGradientTheme) {
      return this;
    }
    return PremiumGradientTheme(
      background: Gradient.lerp(background, other.background, t) ?? background,
    );
  }
}
