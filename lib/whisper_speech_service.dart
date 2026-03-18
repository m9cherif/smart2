import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WhisperSpeechService {
  String? _apiKey;
  bool _useWhisper = true;

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  void setUseWhisper(bool useWhisper) {
    _useWhisper = useWhisper;
  }

  // Transcribe audio file using Whisper
  Future<String> transcribeAudioFile(
    String audioFilePath, {
    WhisperLanguage language = WhisperLanguage.arabic,
    bool enableWordTimestamps = false,
    WhisperModel model = WhisperModel.whisper1,
    double temperature = 0.0,
  }) async {
    if (!_useWhisper || _apiKey == null) {
      return '';
    }

    try {
      final File audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        return '';
      }

      final Uint8List audioBytes = await audioFile.readAsBytes();
      return await _transcribeAudioBytes(
        audioBytes,
        language: language,
        enableWordTimestamps: enableWordTimestamps,
        model: model,
        temperature: temperature,
      );
    } catch (e) {
      return '';
    }
  }

  // Transcribe audio bytes directly
  Future<String> transcribeAudioBytes(
    Uint8List audioBytes, {
    WhisperLanguage language = WhisperLanguage.arabic,
    bool enableWordTimestamps = false,
    WhisperModel model = WhisperModel.whisper1,
    double temperature = 0.0,
  }) async {
    if (!_useWhisper || _apiKey == null) {
      return '';
    }

    return await _transcribeAudioBytes(
      audioBytes,
      language: language,
      enableWordTimestamps: enableWordTimestamps,
      model: model,
      temperature: temperature,
    );
  }

  Future<String> _transcribeAudioBytes(
    Uint8List audioBytes, {
    required WhisperLanguage language,
    required bool enableWordTimestamps,
    required WhisperModel model,
    required double temperature,
  }) async {
    try {
      // Create multipart request for audio file
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'multipart/form-data',
      });

      // Add audio file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          audioBytes,
          filename: 'audio.wav',
        ),
      );

      // Add form fields
      request.fields['model'] = model.apiValue;
      request.fields['language'] = language.code;
      request.fields['temperature'] = temperature.toString();
      
      if (enableWordTimestamps) {
        request.fields['timestamp_granularities[]'] = 'word';
        request.fields['response_format'] = 'verbose_json';
      } else {
        request.fields['response_format'] = 'json';
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['text'] as String? ?? '';
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  // Get supported languages
  List<WhisperLanguage> getSupportedLanguages() {
    return WhisperLanguage.values;
  }
}

enum WhisperLanguage {
  arabic('ar', 'Arabic'),
  english('en', 'English'),
  spanish('es', 'Spanish'),
  french('fr', 'French'),
  german('de', 'German'),
  italian('it', 'Italian'),
  portuguese('pt', 'Portuguese'),
  dutch('nl', 'Dutch'),
  russian('ru', 'Russian'),
  chinese('zh', 'Chinese'),
  japanese('ja', 'Japanese'),
  korean('ko', 'Korean'),
  hindi('hi', 'Hindi'),
  turkish('tr', 'Turkish'),
  polish('pl', 'Polish'),
  swedish('sv', 'Swedish'),
  danish('da', 'Danish'),
  finnish('fi', 'Finnish'),
  norwegian('no', 'Norwegian');

  const WhisperLanguage(this.code, this.displayName);
  
  final String code;
  final String displayName;

  static WhisperLanguage fromCode(String? code) {
    return values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => WhisperLanguage.english,
    );
  }
}

enum WhisperModel {
  whisper1('whisper-1');

  const WhisperModel(this.apiValue);
  final String apiValue;
}
