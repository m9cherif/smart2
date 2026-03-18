import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  SpeechService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  bool _useWhisper = true;

  void setUseWhisper(bool useWhisper) {
    _useWhisper = useWhisper;
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
    var transcript = '';
    Timer? timer;

    // Configure locale for speech recognition
    String? localeId;
    if (locale != null) {
      switch (locale.languageCode) {
        case 'ar':
          // Try multiple Arabic locales for better compatibility
          localeId = 'ar_SA'; // Arabic (Saudi Arabia) - primary
          // Fallback options could be added here if needed
          break;
        case 'fr':
          localeId = 'fr_FR'; // French (France)
          break;
        case 'en':
        default:
          localeId = 'en_US'; // English (US)
          break;
      }
    }

    final available = await _speech.initialize(
      onError: (error) {
        timer?.cancel();
        if (!completer.isCompleted) {
          // Check if the error is related to unsupported language
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
    );

    if (!available) {
      throw StateError('Speech recognition is unavailable on this device.');
    }

    timer = Timer(duration, () {
      unawaited(_speech.stop());
      if (!completer.isCompleted) {
        completer.complete(transcript.trim());
      }
    });

    await _speech.listen(
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
      ),
      localeId: localeId,
      onResult: (result) {
        transcript = result.recognizedWords;
        if (result.finalResult && !completer.isCompleted) {
          timer?.cancel();
          unawaited(_speech.stop());
          completer.complete(transcript.trim());
        }
      },
    );

    final spokenText = await completer.future;
    timer.cancel();
    return spokenText;
  }
}
