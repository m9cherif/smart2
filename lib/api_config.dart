import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_student_ai/google_ocr_service.dart';
import 'speech_service.dart';

class APIConfig {
  static Future<void> initializeServices(GoogleOCRService ocrService, SpeechService speechService) async {
    // No enhanced services to initialize - using local methods only
    // Clear any existing enhanced service settings if they exist
    await clearAllSettings();
  }

  static Future<void> clearAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
