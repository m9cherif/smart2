import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  SpeechService._internal({SpeechToText? speech}) : _speech = speech ?? SpeechToText();
  
  static final SpeechService instance = SpeechService._internal();
  
  // Factory constructor for backward compatibility if needed, 
  // but we prefer using .instance
  factory SpeechService({SpeechToText? speech}) => instance;

  final SpeechToText _speech;
  bool _useWhisper = true;
  bool _isInitialized = false;

  void setUseWhisper(bool useWhisper) {
    _useWhisper = useWhisper;
  }

  Completer<String>? _activeCompleter;
  String _currentTranscript = '';

  Future<void> stop() async {
    await _speech.stop();
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete(_currentTranscript.trim());
      _activeCompleter = null;
    }
  }

  Future<String> record({
    Duration duration = const Duration(seconds: 5),
    Locale? locale,
  }) async {
    if (_useWhisper) {
      // For Whisper, we need to record to a file first
      // This is a simplified implementation - in practice, you'd use a proper audio recording library
      // For now, return local result
      try {
        final localResult = await _recordWithLocalSpeech(duration: duration, locale: locale);
        return localResult;
      } catch (e) {
        debugPrint('Local speech recognition failed: $e');
      }
    }
    
    // Fallback to local speech recognition
    return await _recordWithLocalSpeech(duration: duration, locale: locale);
  }

  Future<String> _recordWithLocalSpeech({
    required Duration duration,
    required Locale? locale,
  }) async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    final completer = Completer<String>();
    _activeCompleter = completer;
    _currentTranscript = '';

    // Set up locale if provided
    String? localeId;
    if (locale != null) {
      final lang = locale.languageCode;
      if (lang == 'ar') {
        localeId = 'ar_SA';
      } else if (lang == 'fr') localeId = 'fr_FR';
      else if (lang == 'en') localeId = 'en_US';
      else localeId = lang;
    }

    if (!_isInitialized) {
      debugPrint('Initializing SpeechToText...');
      try {
        final available = await _speech.initialize(
          onError: (error) {
            debugPrint('Speech recognition error: ${error.errorMsg}');
            if (!completer.isCompleted) {
              final msg = error.errorMsg.toLowerCase();
              if (msg.contains('not available') || msg.contains('not_implemented') || msg.contains('error_no_match')) {
                 completer.completeError('Voice recognition is not available or supported on this system.');
              } else {
                 completer.completeError(error.errorMsg);
              }
            }
          },
          onStatus: (status) {
            debugPrint('Speech recognition status: $status');
            if (status == 'notListening' && !completer.isCompleted && _currentTranscript.isNotEmpty) {
              completer.complete(_currentTranscript.trim());
            }
          },
          debugLogging: true,
        );

        if (!available) {
          _isInitialized = false;
          throw 'Speech recognition is not available at this time. Please check your microphone permissions and try again.';
        }
        _isInitialized = true;
        debugPrint('SpeechToText initialized successfully');
      } catch (e) {
        _isInitialized = false;
        debugPrint('Speech initialization exception: $e');
        return 'Voice recognition error: $e';
      }
    }

    try {
      // Start listening with timeout
      await _speech.listen(
        listenFor: duration,
        pauseFor: const Duration(seconds: 3),
        localeId: localeId,
        onResult: (result) {
          _currentTranscript = result.recognizedWords;
          debugPrint('Recognized: $_currentTranscript (final: ${result.finalResult})');
          if (result.finalResult && !completer.isCompleted) {
            completer.complete(_currentTranscript.trim());
          }
        },
      );

      // Backup timeout in case plugin doesn't call onResult with finalResult
      Timer(duration + const Duration(seconds: 1), () {
        if (!completer.isCompleted) {
          _speech.stop();
          completer.complete(_currentTranscript.trim());
        }
      });

      final result = await completer.future;
      _activeCompleter = null;
      return result;
    } catch (e) {
      _activeCompleter = null;
      debugPrint('Speech listening error: $e');
      return 'Error recording voice: $e';
    }
  }
}
