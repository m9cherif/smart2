import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EnhancedSpeechService {
  static const String _baseUrl = 'https://api.openai.com/v1/audio/transcriptions';
  
  String? _apiKey;

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  // Real-time speech recognition (short audio)
  Future<SpeechResult> recognizeSpeechFromFile(
    String audioFilePath, {
    String language = 'ar-SA',
    bool enableAutomaticPunctuation = true,
    bool enableWordTimeOffsets = false,
    SpeechModel model = SpeechModel.latest,
    int sampleRateHertz = 16000,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('OpenAI Whisper API key not set. Please set the API key first.');
    }

    try {
      final File audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found: $audioFilePath');
      }

      final Uint8List audioBytes = await audioFile.readAsBytes();
      return await _recognizeSpeechFromBytes(
        audioBytes,
        language: language,
        enableAutomaticPunctuation: enableAutomaticPunctuation,
        enableWordTimeOffsets: enableWordTimeOffsets,
        model: model,
        sampleRateHertz: sampleRateHertz,
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to recognize speech: $e');
    }
  }

  // Recognition from audio bytes
  Future<SpeechResult> recognizeSpeechFromBytes(
    Uint8List audioBytes, {
    String language = 'ar-SA',
    bool enableAutomaticPunctuation = true,
    bool enableWordTimeOffsets = false,
    SpeechModel model = SpeechModel.latest,
    int sampleRateHertz = 16000,
  }) async {
    return await _recognizeSpeechFromBytes(
      audioBytes,
      language: language,
      enableAutomaticPunctuation: enableAutomaticPunctuation,
      enableWordTimeOffsets: enableWordTimeOffsets,
      model: model,
      sampleRateHertz: sampleRateHertz,
    );
  }

  Future<SpeechResult> _recognizeSpeechFromBytes(
    Uint8List audioBytes, {
    required String language,
    required bool enableAutomaticPunctuation,
    required bool enableWordTimeOffsets,
    required SpeechModel model,
    required int sampleRateHertz,
  }) async {
    final Map<String, dynamic> requestBody = {
      'config': {
        'encoding': 'WEBM_OPUS', // Adjust based on your audio format
        'sampleRateHertz': sampleRateHertz,
        'languageCode': language,
        'enableAutomaticPunctuation': enableAutomaticPunctuation,
        'enableWordTimeOffsets': enableWordTimeOffsets,
        'model': model.value,
        'useEnhanced': true,
        'adaptation': {
          'phraseSets': [
            {
              'phrases': _getCommonPhrasesForLanguage(language),
            }
          ]
        }
      },
      'audio': {
        'content': base64Encode(audioBytes),
      }
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return _parseSpeechResult(responseData);
      } else {
        throw Exception('Google Speech-to-Text API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to recognize speech: $e');
    }
  }

  // Long-running recognition for longer audio files
  Future<String> recognizeLongAudio(
    String audioFilePath, {
    String language = 'ar-SA',
    bool enableAutomaticPunctuation = true,
    bool enableWordTimeOffsets = false,
    SpeechModel model = SpeechModel.latest,
    int sampleRateHertz = 16000,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('OpenAI Whisper API key not set. Please set the API key first.');
    }

    try {
      final File audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found: $audioFilePath');
      }

      // Transcribe audio using OpenAI Whisper
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl'));
      request.headers.addAll({
        'Authorization': 'Bearer $_apiKey',
      });
      
      request.files.add(await http.MultipartFile.fromPath('file', audioFilePath));
      request.fields['model'] = 'whisper-1';
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return _parseWhisperResult(responseData).transcript;
      } else {
        throw Exception('OpenAI Whisper API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to recognize long audio: $e');
    }
  }

  SpeechResult _parseWhisperResult(Map<String, dynamic> responseData) {
    final String transcript = responseData['text'] ?? '';
    return SpeechResult(
      transcript: transcript,
      confidence: 1.0, // OpenAI Whisper doesn't provide confidence scores
      wordTimings: [], // Word-level timing not available in basic Whisper response
    );
  }

  SpeechResult _parseSpeechResult(Map<String, dynamic> responseData) {
    try {
      if (responseData.containsKey('results')) {
        final results = responseData['results'] as List;
        if (results.isNotEmpty) {
          final firstResult = results[0] as Map<String, dynamic>;
          if (firstResult.containsKey('alternatives')) {
            final alternatives = firstResult['alternatives'] as List;
            if (alternatives.isNotEmpty) {
              final bestAlternative = alternatives[0] as Map<String, dynamic>;
              final transcript = bestAlternative['transcript'] as String? ?? '';
              final confidence = (bestAlternative['confidence'] as num?)?.toDouble() ?? 0.0;
              
              // Extract word timings if available
              final List<WordTiming> wordTimings = [];
              if (bestAlternative.containsKey('words')) {
                final words = bestAlternative['words'] as List;
                for (final word in words) {
                  if (word is Map) {
                    final startTime = word['startTime'] as Map<String, dynamic>?;
                    final endTime = word['endTime'] as Map<String, dynamic>?;
                    
                    wordTimings.add(WordTiming(
                      word: word['word'] as String? ?? '',
                      startTime: _parseTimeOffset(startTime),
                      endTime: _parseTimeOffset(endTime),
                      confidence: (word['confidence'] as num?)?.toDouble() ?? 0.0,
                    ));
                  }
                }
              }

              return SpeechResult(
                transcript: transcript,
                confidence: confidence,
                wordTimings: wordTimings,
              );
            }
          }
        }
      }

      return SpeechResult(transcript: '', confidence: 0.0);
    } catch (e) {
      return SpeechResult(transcript: '', confidence: 0.0, error: e.toString());
    }
  }

  Duration _parseTimeOffset(Map<String, dynamic>? timeOffset) {
    if (timeOffset == null) return Duration.zero;
    
    final seconds = (timeOffset['seconds'] as num?)?.toInt() ?? 0;
    final nanos = (timeOffset['nanos'] as num?)?.toInt() ?? 0;
    
    return Duration(seconds: seconds, microseconds: nanos ~/ 1000);
  }

  List<String> _getCommonPhrasesForLanguage(String language) {
    switch (language) {
      case 'ar-SA':
        return [
          'مرحبا', 'شكرا', 'من فضلك', 'نعم', 'لا', 'السلام عليكم',
          'أهلاً', 'معذرة', 'أنا', 'أنت', 'هو', 'هي', 'نحن', 'أنتم', 'هم',
          'الدرس', 'المدرسة', 'المعلم', 'الطالب', 'الكتاب', 'القلم',
        ];
      case 'en-US':
        return [
          'hello', 'thank you', 'please', 'yes', 'no', 'goodbye',
          'welcome', 'sorry', 'I', 'you', 'he', 'she', 'we', 'they',
          'lesson', 'school', 'teacher', 'student', 'book', 'pen',
        ];
      case 'fr-FR':
        return [
          'bonjour', 'merci', 's\'il vous plaît', 'oui', 'non', 'au revoir',
          'bienvenue', 'désolé', 'je', 'tu', 'il', 'elle', 'nous', 'vous', 'ils', 'elles',
          'leçon', 'école', 'professeur', 'étudiant', 'livre', 'stylo',
        ];
      default:
        return [];
    }
  }

  // Streaming recognition (for real-time applications)
  Stream<SpeechResult> recognizeSpeechStream({
    String language = 'ar-SA',
    bool enableAutomaticPunctuation = true,
    bool enableWordTimeOffsets = false,
    SpeechModel model = SpeechModel.latest,
    int sampleRateHertz = 16000,
  }) {
    // This would require WebSocket implementation for real streaming
    // For now, return an empty stream
    return Stream.empty();
  }

  // Get supported languages
  Future<List<SupportedLanguage>> getSupportedLanguages() async {
    // OpenAI Whisper supports many languages
    // This is a subset of commonly used languages
    return [
      SupportedLanguage(code: 'ar-SA', name: 'Arabic (Saudi Arabia)'),
      SupportedLanguage(code: 'ar-EG', name: 'Arabic (Egypt)'),
      SupportedLanguage(code: 'ar-AE', name: 'Arabic (UAE)'),
      SupportedLanguage(code: 'en-US', name: 'English (United States)'),
      SupportedLanguage(code: 'en-GB', name: 'English (United Kingdom)'),
      SupportedLanguage(code: 'fr-FR', name: 'French (France)'),
      SupportedLanguage(code: 'es-ES', name: 'Spanish (Spain)'),
      SupportedLanguage(code: 'de-DE', name: 'German (Germany)'),
      SupportedLanguage(code: 'it-IT', name: 'Italian (Italy)'),
      SupportedLanguage(code: 'pt-BR', name: 'Portuguese (Brazil)'),
      SupportedLanguage(code: 'zh-CN', name: 'Chinese (Simplified)'),
      SupportedLanguage(code: 'ja-JP', name: 'Japanese'),
      SupportedLanguage(code: 'ko-KR', name: 'Korean'),
      SupportedLanguage(code: 'ru-RU', name: 'Russian'),
      SupportedLanguage(code: 'hi-IN', name: 'Hindi'),
    ];
  }
}

class SpeechResult {
  final String transcript;
  final double confidence;
  final List<WordTiming> wordTimings;
  final String? error;

  const SpeechResult({
    required this.transcript,
    required this.confidence,
    this.wordTimings = const [],
    this.error,
  });

  bool get hasError => error != null;
  bool get hasTranscript => transcript.isNotEmpty;
  bool get isConfident => confidence > 0.8;
}

class WordTiming {
  final String word;
  final Duration startTime;
  final Duration endTime;
  final double confidence;

  const WordTiming({
    required this.word,
    required this.startTime,
    required this.endTime,
    required this.confidence,
  });

  Duration get duration => endTime - startTime;
}

class SupportedLanguage {
  final String code;
  final String name;

  const SupportedLanguage({
    required this.code,
    required this.name,
  });
}

enum SpeechModel {
  latest('latest_long'),
  short('short'),
  commandAndSearch('command_and_search'),
  phoneCall('phone_call'),
  video('video'),
  default_('default');

  const SpeechModel(this.value);
  final String value;
}
