import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'package:smart_student_ai/google_ocr_service.dart' as ocr_service;
import 'speech_service.dart';

enum AppLanguage { english, french, arabic }

enum AppBrightnessMode { light, dark }

enum AppThemeOption { ocean, sunrise, forest, custom }

enum AppGrade { primary7, primary8, primary9 }

class AppThemeSpec {
  const AppThemeSpec({
    required this.option,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.surface,
    required this.darkSurface,
    required this.heroForeground,
    required this.darkHeroForeground,
    required this.pageGradient,
    required this.darkPageGradient,
    required this.heroGradient,
    required this.darkHeroGradient,
  });

  final AppThemeOption option;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color surface;
  final Color darkSurface;
  final Color heroForeground;
  final Color darkHeroForeground;
  final List<Color> pageGradient;
  final List<Color> darkPageGradient;
  final List<Color> heroGradient;
  final List<Color> darkHeroGradient;

  Color surfaceFor(AppBrightnessMode mode) {
    return mode == AppBrightnessMode.dark ? darkSurface : surface;
  }

  Color heroForegroundFor(AppBrightnessMode mode) {
    return mode == AppBrightnessMode.dark
        ? darkHeroForeground
        : heroForeground;
  }

  List<Color> pageGradientFor(AppBrightnessMode mode) {
    return mode == AppBrightnessMode.dark ? darkPageGradient : pageGradient;
  }

  List<Color> heroGradientFor(AppBrightnessMode mode) {
    return mode == AppBrightnessMode.dark ? darkHeroGradient : heroGradient;
  }

  static const List<AppThemeSpec> values = <AppThemeSpec>[
    AppThemeSpec(
      option: AppThemeOption.ocean,
      primary: Color(0xFF0F4C81),
      secondary: Color(0xFFE38B29),
      tertiary: Color(0xFF2A7F62),
      surface: Color(0xFFF8FBFF),
      darkSurface: Color(0xFF0F1720),
      heroForeground: Color(0xFFE8F3FF),
      darkHeroForeground: Color(0xFFEAF4FF),
      pageGradient: <Color>[Color(0xFFEAF1FA), Color(0xFFF7F9FC)],
      darkPageGradient: <Color>[Color(0xFF07111B), Color(0xFF0F1823)],
      heroGradient: <Color>[Color(0xFF0F4C81), Color(0xFF163B5A)],
      darkHeroGradient: <Color>[Color(0xFF133A5D), Color(0xFF091827)],
    ),
    AppThemeSpec(
      option: AppThemeOption.sunrise,
      primary: Color(0xFF8C3B1A),
      secondary: Color(0xFFFFB347),
      tertiary: Color(0xFF7A1E48),
      surface: Color(0xFFFFFAF4),
      darkSurface: Color(0xFF1C1611),
      heroForeground: Color(0xFFFFE9D1),
      darkHeroForeground: Color(0xFFFFE8D0),
      pageGradient: <Color>[Color(0xFFFFF1E5), Color(0xFFFDF8F3)],
      darkPageGradient: <Color>[Color(0xFF16110D), Color(0xFF231913)],
      heroGradient: <Color>[Color(0xFF8C3B1A), Color(0xFFDC6B2F)],
      darkHeroGradient: <Color>[Color(0xFF6E3119), Color(0xFF2B120D)],
    ),
    AppThemeSpec(
      option: AppThemeOption.forest,
      primary: Color(0xFF1F6E53),
      secondary: Color(0xFFDB7C2F),
      tertiary: Color(0xFF274C77),
      surface: Color(0xFFF6FCF8),
      darkSurface: Color(0xFF101914),
      heroForeground: Color(0xFFE2F7EC),
      darkHeroForeground: Color(0xFFE1F6EB),
      pageGradient: <Color>[Color(0xFFEAF6F0), Color(0xFFF7FBF8)],
      darkPageGradient: <Color>[Color(0xFF0C1410), Color(0xFF132019)],
      heroGradient: <Color>[Color(0xFF1F6E53), Color(0xFF153D34)],
      darkHeroGradient: <Color>[Color(0xFF1A5944), Color(0xFF0B211B)],
    ),
  ];

  static AppThemeSpec fromOption(AppThemeOption option, [Color? customColor]) {
    if (option == AppThemeOption.custom && customColor != null) {
      return fromSeedColor(customColor);
    }
    return values.firstWhere(
      (spec) => spec.option == option,
      orElse: () => values.first,
    );
  }

  /// Generates a complete theme spec from a single seed color.
  static AppThemeSpec fromSeedColor(Color seed) {
    final hsl = HSLColor.fromColor(seed);
    final h = hsl.hue;
    final s = hsl.saturation;
    final l = hsl.lightness;

    // Primary: the seed itself, clamped to a pleasant saturation/lightness
    final primary = HSLColor.fromAHSL(1, h, s.clamp(0.35, 0.85), l.clamp(0.25, 0.45)).toColor();

    // Secondary: complementary hue shift (+40°), warmer
    final secondary = HSLColor.fromAHSL(1, (h + 40) % 360, (s * 0.9).clamp(0.4, 0.85), 0.55).toColor();

    // Tertiary: analogous hue shift (-50°)
    final tertiary = HSLColor.fromAHSL(1, (h + 310) % 360, (s * 0.8).clamp(0.3, 0.7), 0.35).toColor();

    // Surfaces
    final surface = HSLColor.fromAHSL(1, h, (s * 0.15).clamp(0.05, 0.2), 0.97).toColor();
    final darkSurface = HSLColor.fromAHSL(1, h, (s * 0.2).clamp(0.05, 0.25), 0.08).toColor();

    // Hero foreground (light tinted white)
    final heroFg = HSLColor.fromAHSL(1, h, (s * 0.3).clamp(0.1, 0.4), 0.93).toColor();
    final darkHeroFg = HSLColor.fromAHSL(1, h, (s * 0.3).clamp(0.1, 0.4), 0.94).toColor();

    // Page gradients
    final pg1 = HSLColor.fromAHSL(1, h, (s * 0.18).clamp(0.05, 0.25), 0.95).toColor();
    final pg2 = HSLColor.fromAHSL(1, h, (s * 0.1).clamp(0.02, 0.15), 0.98).toColor();
    final dpg1 = HSLColor.fromAHSL(1, h, (s * 0.2).clamp(0.05, 0.25), 0.05).toColor();
    final dpg2 = HSLColor.fromAHSL(1, h, (s * 0.15).clamp(0.05, 0.2), 0.08).toColor();

    // Hero gradients
    final hg1 = primary;
    final hg2 = HSLColor.fromAHSL(1, h, (s * 0.9).clamp(0.3, 0.8), (l * 0.7).clamp(0.18, 0.35)).toColor();
    final dhg1 = HSLColor.fromAHSL(1, h, (s * 0.85).clamp(0.3, 0.75), (l * 0.6).clamp(0.15, 0.3)).toColor();
    final dhg2 = HSLColor.fromAHSL(1, h, (s * 0.6).clamp(0.2, 0.5), 0.08).toColor();

    return AppThemeSpec(
      option: AppThemeOption.custom,
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface: surface,
      darkSurface: darkSurface,
      heroForeground: heroFg,
      darkHeroForeground: darkHeroFg,
      pageGradient: <Color>[pg1, pg2],
      darkPageGradient: <Color>[dpg1, dpg2],
      heroGradient: <Color>[hg1, hg2],
      darkHeroGradient: <Color>[dhg1, dhg2],
    );
  }
}

class AppController extends ChangeNotifier {
  static const String _themeKey = 'app_theme_option';
  static const String _brightnessKey = 'app_brightness_mode';
  static const String _languageKey = 'app_language';
  static const String _gradeKey = 'app_grade';
  static const String _gradeSelectedKey = 'grade_selected';
  static const String _customColorKey = 'app_custom_color';

  SharedPreferences? _preferences;
  AppThemeOption _themeOption = AppThemeOption.ocean;
  AppBrightnessMode _brightnessMode = AppBrightnessMode.light;
  AppLanguage _language = AppLanguage.english;
  AppGrade _grade = AppGrade.primary7;
  bool _gradeSelected = false;
  Color _customColor = const Color(0xFF6750A4); // default custom color (purple)

  AppThemeOption get themeOption => _themeOption;
  AppBrightnessMode get brightnessMode => _brightnessMode;
  AppLanguage get language => _language;
  AppGrade get grade => _grade;
  bool get gradeSelected => _gradeSelected;
  Color get customColor => _customColor;
  AppThemeSpec get themeSpec => AppThemeSpec.fromOption(_themeOption, _customColor);
  Locale get locale => switch (_language) {
    AppLanguage.english => const Locale('en'),
    AppLanguage.french => const Locale('fr'),
    AppLanguage.arabic => const Locale('ar'),
  };

  ThemeData get themeData => buildAppTheme(themeSpec, _brightnessMode);

  Future<void> load() async {
    final preferences = await _ensurePreferences();
    final nextTheme = _themeFromName(preferences.getString(_themeKey));
    final nextBrightness = _brightnessFromName(
      preferences.getString(_brightnessKey),
    );
    final nextLanguage = _languageFromName(preferences.getString(_languageKey));
    final nextGrade = _gradeFromName(preferences.getString(_gradeKey));
    final nextGradeSelected = preferences.getBool(_gradeSelectedKey) ?? false;
    final savedColorValue = preferences.getInt(_customColorKey);
    final nextCustomColor = savedColorValue != null
        ? Color(savedColorValue)
        : const Color(0xFF6750A4);

    // Initialize API services with saved configuration
    final ocrService = ocr_service.GoogleOCRService();
    final speechService = SpeechService();
    await APIConfig.initializeServices(ocrService, speechService);

    _themeOption = nextTheme;
    _brightnessMode = nextBrightness;
    _language = nextLanguage;
    _grade = nextGrade;
    _gradeSelected = nextGradeSelected;
    _customColor = nextCustomColor;
    notifyListeners();
  }

  Future<void> updateTheme(AppThemeOption value) async {
    if (_themeOption == value) {
      return;
    }

    _themeOption = value;
    notifyListeners();
    final preferences = await _ensurePreferences();
    await preferences.setString(_themeKey, value.name);
  }

  Future<void> updateCustomColor(Color value) async {
    if (_customColor == value) {
      return;
    }

    _customColor = value;
    // When picking a custom color, automatically switch to custom theme
    _themeOption = AppThemeOption.custom;
    notifyListeners();
    final preferences = await _ensurePreferences();
    await preferences.setInt(_customColorKey, value.toARGB32());
    await preferences.setString(_themeKey, AppThemeOption.custom.name);
  }

  Future<void> updateBrightnessMode(AppBrightnessMode value) async {
    if (_brightnessMode == value) {
      return;
    }

    _brightnessMode = value;
    notifyListeners();
    final preferences = await _ensurePreferences();
    await preferences.setString(_brightnessKey, value.name);
  }

  Future<void> updateLanguage(AppLanguage value) async {
    if (_language == value) {
      return;
    }

    _language = value;
    notifyListeners();
    final preferences = await _ensurePreferences();
    await preferences.setString(_languageKey, value.name);
  }

  Future<void> updateGrade(AppGrade value) async {
    if (_grade == value) {
      return;
    }

    _grade = value;
    _gradeSelected = true;
    notifyListeners();
    final preferences = await _ensurePreferences();
    await preferences.setString(_gradeKey, value.name);
    await preferences.setBool(_gradeSelectedKey, true);
  }


  Future<SharedPreferences> _ensurePreferences() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  AppThemeOption _themeFromName(String? value) {
    return AppThemeOption.values.firstWhere(
      (option) => option.name == value,
      orElse: () => AppThemeOption.ocean,
    );
  }

  AppBrightnessMode _brightnessFromName(String? value) {
    return AppBrightnessMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppBrightnessMode.light,
    );
  }

  AppLanguage _languageFromName(String? value) {
    return AppLanguage.values.firstWhere(
      (language) => language.name == value,
      orElse: () => AppLanguage.english,
    );
  }

  AppGrade _gradeFromName(String? value) {
    return AppGrade.values.firstWhere(
      (grade) => grade.name == value,
      orElse: () => AppGrade.primary7,
    );
  }
}

class TaskEvents extends ChangeNotifier {
  static final TaskEvents instance = TaskEvents._();
  TaskEvents._();

  void refresh() {
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing from the widget tree.');
    return scope!.notifier!;
  }
}

ThemeData buildAppTheme(AppThemeSpec spec, AppBrightnessMode mode) {
  final isDark = mode == AppBrightnessMode.dark;
  final brightness = isDark ? Brightness.dark : Brightness.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: spec.primary,
      brightness: brightness,
    ),
  );
  
  final surface = spec.surfaceFor(mode);
  final onSurface = isDark ? Colors.white.withValues(alpha: 0.95) : Colors.black.withValues(alpha: 0.9);
  final onPrimary = isDark ? Colors.white : Colors.black;

  final colorScheme = base.colorScheme.copyWith(
    primary: spec.primary,
    secondary: spec.secondary,
    tertiary: spec.tertiary,
    surface: surface,
    onSurface: onSurface,
    onPrimary: onPrimary,
    onSecondary: onSurface,
    onError: onSurface,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: spec.pageGradientFor(mode).last,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.2 : 0.35),
        ),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      },
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: TextStyle(color: onSurface.withValues(alpha: 0.7)),
      hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.5)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: BorderSide(color: colorScheme.primary, width: 1.2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? colorScheme.surfaceContainerHighest : colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: isDark ? onSurface : colorScheme.onInverseSurface),
    ),
    textTheme: base.textTheme
        .apply(bodyColor: onSurface, displayColor: onSurface)
        .copyWith(
          headlineLarge: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.4,
            height: 1.0,
          ),
          headlineMedium: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
          headlineSmall: TextStyle(
            color: onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          titleLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(color: onSurface, height: 1.5),
          bodyMedium: TextStyle(color: onSurface, height: 1.45),
        ),
  );
}
