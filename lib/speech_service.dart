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
    Timer? timer;

    // Configure locale for speech recognition
    String? localeId;
    if (locale != null) {
      switch (locale.languageCode) {
        case 'ar':
          localeId = 'ar_SA'; 
          break;
        case 'fr':
          localeId = 'fr_FR'; 
          break;
        case 'en':
        default:
          localeId = 'en_US'; 
          break;
      }
    }

    if (!_isInitialized) {
      debugPrint('Initializing SpeechToText...');
      final available = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: ${error.errorMsg}');
          timer?.cancel();
          if (!completer.isCompleted) {
            if (error.errorMsg.contains('not available') || 
                error.errorMsg.contains('language') ||
                error.errorMsg.contains('locale')) {
              completer.completeError(
                StateError('Speech recognition not available for ${locale?.languageCode ?? "this language"}. '
                          'Please try using English or check if your device supports this language.')
              );
            } else {
              completer.completeError(StateError(error.errorMsg));
            }
          }
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
        },
      );

      if (!available) {
        debugPrint('Speech recognition initialization failed');
        _isInitialized = false;
        throw StateError('Speech recognition is unavailable on this device.');
      }
      _isInitialized = true;
      debugPrint('SpeechToText initialized successfully');
    }

    // Create a timer that will complete the transcript if no final result is received
    final transcriptTimer = Timer(duration, () {
      debugPrint('Speech recognition timer expired');
      unawaited(_speech.stop());
      if (!completer.isCompleted) {
        completer.complete(_currentTranscript.trim());
      }
    });
    timer = transcriptTimer;

    await _speech.listen(
      listenFor: duration,
      pauseFor: const Duration(seconds: 2), // Stop automatically after 2 seconds of silence
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      ),
      localeId: localeId,
      onResult: (result) {
        _currentTranscript = result.recognizedWords;
        debugPrint('Recognized words: $_currentTranscript (final: ${result.finalResult})');
        if (result.finalResult && !completer.isCompleted) {
          transcriptTimer.cancel();
          unawaited(_speech.stop());
          completer.complete(_currentTranscript.trim());
        }
      },
    );

    final spokenText = await completer.future;
    transcriptTimer.cancel();
    _activeCompleter = null;
    return spokenText;
  }
}
