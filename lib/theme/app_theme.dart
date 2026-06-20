import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic colour tokens — adapt to dark/light theme automatically.
/// Access via `context.col` anywhere you have a BuildContext.
class AppColorSet extends ThemeExtension<AppColorSet> {
  const AppColorSet({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceOutline,
    required this.accent,
    required this.accentMuted,
    required this.ledAccent,
    required this.ledAccentMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.divider,
    required this.navBackground,
  });

  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceOutline;
  final Color accent;
  final Color accentMuted;
  final Color ledAccent;
  final Color ledAccentMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color divider;
  final Color navBackground;

  static const dark = AppColorSet(
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF151515),
    surfaceRaised: Color(0xFF1E1E1E),
    surfaceOutline: Color(0xFF2A2A2A),
    accent: Color(0xFFD4A256),
    accentMuted: Color(0xFF3A2E1C),
    ledAccent: Color(0xFFC47B6E),
    ledAccentMuted: Color(0xFF3A2622),
    textPrimary: Color(0xFFF5F1EA),
    textSecondary: Color(0xFFA8A29E),
    textTertiary: Color(0xFF6B6660),
    success: Color(0xFF7FB88A),
    warning: Color(0xFFE0B04D),
    danger: Color(0xFFD2685A),
    divider: Color(0xFF232323),
    navBackground: Color(0xFF111111),
  );

  static const light = AppColorSet(
    background: Color(0xFFF5F0E8),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF0EAE0),
    surfaceOutline: Color(0xFFE5DDD2),
    accent: Color(0xFFC49040),
    accentMuted: Color(0xFFFAF0DC),
    ledAccent: Color(0xFFB86050),
    ledAccentMuted: Color(0xFFFAE8E4),
    textPrimary: Color(0xFF1C1510),
    textSecondary: Color(0xFF6B5A48),
    textTertiary: Color(0xFF9C8A78),
    success: Color(0xFF3A7A4A),
    warning: Color(0xFFB88020),
    danger: Color(0xFFB84035),
    divider: Color(0xFFE5DDD2),
    navBackground: Color(0xFFFAF5EC),
  );

  @override
  AppColorSet copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceOutline,
    Color? accent,
    Color? accentMuted,
    Color? ledAccent,
    Color? ledAccentMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? divider,
    Color? navBackground,
  }) =>
      AppColorSet(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceRaised: surfaceRaised ?? this.surfaceRaised,
        surfaceOutline: surfaceOutline ?? this.surfaceOutline,
        accent: accent ?? this.accent,
        accentMuted: accentMuted ?? this.accentMuted,
        ledAccent: ledAccent ?? this.ledAccent,
        ledAccentMuted: ledAccentMuted ?? this.ledAccentMuted,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textTertiary: textTertiary ?? this.textTertiary,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
        divider: divider ?? this.divider,
        navBackground: navBackground ?? this.navBackground,
      );

  @override
  AppColorSet lerp(AppColorSet? other, double t) {
    if (other is! AppColorSet) return this;
    return AppColorSet(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceOutline: Color.lerp(surfaceOutline, other.surfaceOutline, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      ledAccent: Color.lerp(ledAccent, other.ledAccent, t)!,
      ledAccentMuted: Color.lerp(ledAccentMuted, other.ledAccentMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
    );
  }
}

/// Shorthand: `final c = context.col;`
extension AppColorSetX on BuildContext {
  AppColorSet get col =>
      Theme.of(this).extension<AppColorSet>() ?? AppColorSet.dark;
}

/// Kept for const contexts and monoStyle default.
class AppColors {
  AppColors._();
  static const background = Color(0xFF0A0A0A);
  static const surface = Color(0xFF151515);
  static const surfaceRaised = Color(0xFF1E1E1E);
  static const surfaceOutline = Color(0xFF2A2A2A);
  static const accent = Color(0xFFD4A256);
  static const accentMuted = Color(0xFF3A2E1C);
  static const ledAccent = Color(0xFFC47B6E);
  static const ledAccentMuted = Color(0xFF3A2622);
  static const textPrimary = Color(0xFFF5F1EA);
  static const textSecondary = Color(0xFFA8A29E);
  static const textTertiary = Color(0xFF6B6660);
  static const success = Color(0xFF7FB88A);
  static const warning = Color(0xFFE0B04D);
  static const danger = Color(0xFFD2685A);
  static const divider = Color(0xFF232323);
}

class AppRadius {
  AppRadius._();
  static const card = 16.0;
  static const button = 12.0;
  static const chip = 999.0;
  static const sheet = 24.0;
}

class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Monospace text — timers, counts, IPs, coordinates.
/// Pass `color` explicitly; if null, inherits the theme default.
TextStyle monoStyle({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w500,
  Color? color,
  double? letterSpacing,
}) {
  return GoogleFonts.jetBrainsMono(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        colors: AppColorSet.dark,
        base: ThemeData.dark(useMaterial3: true),
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        colors: AppColorSet.light,
        base: ThemeData.light(useMaterial3: true),
      );

  static ThemeData _build({
    required Brightness brightness,
    required AppColorSet colors,
    required ThemeData base,
  }) {
    final isDark = brightness == Brightness.dark;
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: colors.ledAccent,
        onSecondary: isDark ? Colors.black : Colors.white,
        error: colors.danger,
        onError: Colors.white,
        surface: colors.background,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: colors.surfaceRaised,
        onSurfaceVariant: colors.textSecondary,
        outline: colors.textTertiary,
        outlineVariant: colors.surfaceOutline,
      ),
      textTheme: textTheme,
      extensions: [colors],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: colors.divider,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: colors.surfaceOutline),
        ),
      ),
      iconTheme: IconThemeData(color: colors.textPrimary, size: 22),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.surfaceOutline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.accent,
        inactiveTrackColor: colors.surfaceOutline,
        thumbColor: colors.accent,
        overlayColor: colors.accent.withValues(alpha: 0.15),
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? colors.accent : colors.textTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? colors.accentMuted : colors.surfaceOutline,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: TextStyle(color: colors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: colors.surfaceOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: colors.surfaceOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: colors.accent, width: 1.5),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.divider, thickness: 1, space: 1),
    );
  }
}
