import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'package:smart_student_ai/google_ocr_service.dart' as ocr_service;
import 'speech_service.dart';

enum AppLanguage { english, french, arabic }

enum AppBrightnessMode { light, dark }

enum AppThemeOption { ocean, sunrise, forest }

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

  static AppThemeSpec fromOption(AppThemeOption option) {
    return values.firstWhere((spec) => spec.option == option);
  }
}

class AppController extends ChangeNotifier {
  static const String _themeKey = 'app_theme_option';
  static const String _brightnessKey = 'app_brightness_mode';
  static const String _languageKey = 'app_language';
  static const String _gradeKey = 'app_grade';
  static const String _gradeSelectedKey = 'grade_selected';

  SharedPreferences? _preferences;
  AppThemeOption _themeOption = AppThemeOption.ocean;
  AppBrightnessMode _brightnessMode = AppBrightnessMode.light;
  AppLanguage _language = AppLanguage.english;
  AppGrade _grade = AppGrade.primary7;
  bool _gradeSelected = false;

  AppThemeOption get themeOption => _themeOption;
  AppBrightnessMode get brightnessMode => _brightnessMode;
  AppLanguage get language => _language;
  AppGrade get grade => _grade;
  bool get gradeSelected => _gradeSelected;
  AppThemeSpec get themeSpec => AppThemeSpec.fromOption(_themeOption);
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

    // Initialize API services with saved configuration
    final ocrService = ocr_service.GoogleOCRService();
    final speechService = SpeechService();
    await APIConfig.initializeServices(ocrService, speechService);

    if (nextTheme == _themeOption &&
        nextBrightness == _brightnessMode &&
        nextLanguage == _language &&
        nextGrade == _grade &&
        nextGradeSelected == _gradeSelected) {
      return;
    }

    _themeOption = nextTheme;
    _brightnessMode = nextBrightness;
    _language = nextLanguage;
    _grade = nextGrade;
    _gradeSelected = nextGradeSelected;
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
  final brightness = mode == AppBrightnessMode.dark
      ? Brightness.dark
      : Brightness.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: spec.primary,
      brightness: brightness,
    ),
  );
  final surface = spec.surfaceFor(mode);
  // ensure text remains black regardless of brightness
  final colorScheme = base.colorScheme.copyWith(
    primary: spec.primary,
    secondary: spec.secondary,
    tertiary: spec.tertiary,
    surface: surface,
    onSurface: Colors.black,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onError: Colors.black,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: spec.pageGradientFor(mode).last,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
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
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
    ),
    textTheme: base.textTheme
        // override all colors to black so text never turns white
        .apply(bodyColor: Colors.black, displayColor: Colors.black)
        .copyWith(
          headlineLarge: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.4,
            height: 1.0,
          ),
          headlineMedium: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
          headlineSmall: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          titleLarge: const TextStyle(fontWeight: FontWeight.w700),
          titleMedium: const TextStyle(fontWeight: FontWeight.w700),
          bodyLarge: const TextStyle(height: 1.5),
          bodyMedium: const TextStyle(height: 1.45),
        ),
  );
}
