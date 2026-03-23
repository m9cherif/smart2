import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:smart_student_ai/app_controller.dart';
import 'package:smart_student_ai/app_strings.dart';
import 'package:smart_student_ai/notification_service.dart';
import 'package:smart_student_ai/ai_service.dart';
import 'package:smart_student_ai/tray_service.dart';
import 'package:smart_student_ai/database_service.dart';
import 'launch_gate.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    debugPrint('Main: Starting service initializations...');
    
    await AIService.initialize();
    debugPrint('Main: AIService initialized');
    
    await NotificationService.instance.initialize();
    debugPrint('Main: NotificationService initialized');
    
    await TrayService.instance.initialize();
    debugPrint('Main: TrayService initialized');
    
    // Pre-initialize database to catch storage errors early
    try {
      await DatabaseService.instance.database;
      debugPrint('Main: DatabaseService initialized');
    } catch (dbError) {
      debugPrint('Main: Database initialization failed: $dbError');
      // We don't crash here, but we've logged it
    }

    runApp(const SmartStudentApp());
  } catch (e, stack) {
    debugPrint('Main: FATAL ERROR during startup: $e');
    debugPrint(stack.toString());
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Fatal error during app startup: $e'),
        ),
      ),
    ));
  }
}

class SmartStudentApp extends StatefulWidget {
  const SmartStudentApp({super.key});

  @override
  State<SmartStudentApp> createState() => _SmartStudentAppState();
}

class _SmartStudentAppState extends State<SmartStudentApp> {
  final AppController _controller = AppController();
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => AppStrings.of(context).appName,
            theme: _controller.themeData,
            locale: _controller.locale,
            supportedLocales: const <Locale>[
              Locale('en'),
              Locale('fr'),
              Locale('ar'),
            ],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: FutureBuilder<void>(
              future: _loadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const _LaunchLoadingScreen();
                }
                return const LaunchGate();
              },
            ),
          );
        },
      ),
    );
  }
}

class _LaunchLoadingScreen extends StatelessWidget {
  const _LaunchLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final themeSpec = AppScope.of(context).themeSpec;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeSpec.pageGradient,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'logo.png',
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.school_rounded,
                  size: 80,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
