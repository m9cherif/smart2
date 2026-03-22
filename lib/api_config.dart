import 'package:smart_student_ai/google_ocr_service.dart';
import 'package:smart_student_ai/ai_service.dart';
import 'speech_service.dart';

class APIConfig {
  static Future<void> initializeServices(GoogleOCRService ocrService, SpeechService speechService) async {
    // No enhanced services to initialize - using local and AI methods
    await AIService.initialize();
  }

  static Future<void> clearAllSettings() async {
    // Optional: Only clear specific service-related settings if needed
  }
}
