import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class AIService {
  static const String _apiKey =
      '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';
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static String _lastGeneratedSummary = '';
  static List<Map<String, dynamic>> _lastGeneratedQuiz = [];

  static Future<void> initialize() async {
    // OpenRouter API doesn't need model initialization like Gemini
  }

  // Extract text from PDF using ConvertAPI
  static Future<String> extractTextFromPDF(File pdfFile) async {
    return _convertWithAPI(pdfFile, 'pdf');
  }

  // Extract text from DOCX/DOC using ConvertAPI
  static Future<String> extractTextFromDocx(File docxFile) async {
    return _convertWithAPI(docxFile, 'docx');
  }

  static Future<String> _convertWithAPI(File file, String format) async {
    try {
      if (!await file.exists()) {
        return '$format file not found.';
      }

      // Use the appropriate token and endpoint based on format
      // Users often provide a specific token for doc/docx
      final isDoc = format == 'docx' || format == 'doc';
      final token = isDoc 
          ? 'dRinXxggO8poKc7619ltbl8LYQjyKacH' 
          : 'FnpOXR02fbG81U7WETCOUOn2824nsCuM';
      
      // Use docx endpoint for both .doc and .docx as per user's example
      final apiFormat = isDoc ? 'docx' : format;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://v2.convertapi.com/convert/$apiFormat/to/txt'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      request.fields['StoreFile'] = 'true';
      request.files.add(
        await http.MultipartFile.fromPath('File', file.path),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);

        if (json['Files'] != null && json['Files'].isNotEmpty) {
          final String fileUrl = json['Files'][0]['Url'];
          final textResponse = await http.get(Uri.parse(fileUrl));

          if (textResponse.statusCode == 200) {
            return textResponse.body.isNotEmpty 
                ? textResponse.body 
                : 'No text content found in document.';
          }
          return 'Error downloading text: HTTP ${textResponse.statusCode}';
        }
        return 'Error: No files returned from conversion API';
      } else {
        final responseData = await response.stream.bytesToString();
        return 'Error converting document: HTTP ${response.statusCode}\n$responseData';
      }
    } catch (e) {
      return 'Error extracting text: ${e.toString()}';
    }
  }

  // Extract text from text file
  static Future<String> extractTextFromTextFile(File textFile) async {
    try {
      if (await textFile.exists()) {
        final content = await textFile.readAsString();
        return content.isNotEmpty ? content : 'Empty text file.';
      } else {
        return 'Text file not found.';
      }
    } catch (e) {
      return 'Error reading text file: ${e.toString()}';
    }
  }

  // Process any document (PDF, Docx, Text) with AI to get a summary
  static Future<String> processDocumentSummary(File file) async {
    try {
      final extractedText = await extractTextFromFile(file);
      if (extractedText.isEmpty || extractedText.startsWith('Error')) {
        return 'No readable text could be extracted from this document ($extractedText).';
      }
      return await generateSummary(extractedText);
    } catch (e) {
      return 'Error processing document summary: ${e.toString()}';
    }
  }

  // Process any document (PDF, Docx, Text) with AI to get a quiz
  static Future<List<Map<String, dynamic>>> processDocumentQuiz(File file) async {
    try {
      final extractedText = await extractTextFromFile(file);
      if (extractedText.isEmpty || extractedText.startsWith('Error')) {
        return [];
      }
      return await generateQuiz(extractedText);
    } catch (e) {
      return [];
    }
  }

  // Extract text from any file (PDF, Docx, or text)
  static Future<String> extractTextFromFile(File file) async {
    final path = file.path.toLowerCase();
    if (path.endsWith('.pdf')) {
      return await extractTextFromPDF(file);
    } else if (path.endsWith('.docx') || path.endsWith('.doc')) {
      return await extractTextFromDocx(file);
    } else {
      return await extractTextFromTextFile(file);
    }
  }

  // Vision-based OCR using AI (OpenRouter)
  static Future<String> extractTextFromImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return 'Image file not found.';
      }

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final extension = p.extension(imageFile.path).toLowerCase().replaceFirst('.', '');
      final mimeType = extension == 'jpg' || extension == 'jpeg' ? 'image/jpeg' : 'image/$extension';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://openrouter.ai/',
        },
        body: jsonEncode({
          'model': 'google/gemini-2.0-flash-001', // Vision-capable model
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Please perform OCR on this image. Extract ALL readable text exactly as it appears. If the text is in Arabic, preserve the Arabic characters. Return ONLY the extracted text with no commentary.',
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:$mimeType;base64,$base64Image',
                  },
                },
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final content = responseData['choices'][0]['message']['content'];
        return content?.trim() ?? 'No text extracted from image.';
      } else {
        return 'AI OCR Error: HTTP ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'AI OCR Exception: ${e.toString()}';
    }
  }

  static Future<String> generateSummary(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://openrouter.ai/',
        },
        body: jsonEncode({
          'model': 'openrouter/auto',
          'messages': [
            {
              'role': 'user',
              'content':
                  'Please provide a comprehensive summary of the following text. The summary should be concise but informative, capture the main points and key details, be easy to understand, and maintain the original meaning and context.\n\nText to summarize:\n$text',
            },
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final content = responseData['choices'][0]['message']['content'];
        _lastGeneratedSummary =
            content ?? 'Unable to generate summary. Please try again.';
        return _lastGeneratedSummary;
      } else {
        return 'Error generating summary: HTTP ${response.statusCode}';
      }
    } catch (e) {
      return 'Error generating summary: ${e.toString()}';
    }
  }

  static String get lastGeneratedSummary => _lastGeneratedSummary;

  static Future<List<Map<String, dynamic>>> generateQuiz(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://openrouter.ai/',
        },
        body: jsonEncode({
          'model': 'deepseek/deepseek-chat',
          'messages': [
            {
              'role': 'user',
              'content':
                  'Based on the following text, create a quiz with 5 multiple-choice questions. Each question should test important concepts from the text, have 4 options (A, B, C, D), and include the correct answer at the end.\n\nReturn the response as a JSON array of questions with this format:\n[\n  {\n    "question": "The question text here",\n    "options": ["Option A", "Option B", "Option C", "Option D"],\n    "correct_answer": 0\n  }\n]\n\nIMPORTANT: Return ONLY the JSON array, no additional text or explanations. Each question must be an object with exactly "question", "options", and "correct_answer" fields. Use 0 for A, 1 for B, 2 for C, and 3 for D as the correct_answer index.\n\nText for quiz:\n$text',
            },
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final content = responseData['choices'][0]['message']['content'];

        try {
          final jsonStart = content.indexOf('[');
          final jsonEnd = content.lastIndexOf(']');
          if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
            final jsonStr = content.substring(jsonStart, jsonEnd + 1);

            final List<dynamic> quizData = List<Map<String, dynamic>>.from(
              jsonDecode(jsonStr) as List<dynamic>,
            ).cast<Map<String, dynamic>>().toList();

            final validQuizData = quizData
                .where((item) {
                  final questionObj = item as Map<String, dynamic>;
                  return questionObj.containsKey('question') &&
                      questionObj.containsKey('options') &&
                      questionObj.containsKey('correct_answer') &&
                      questionObj['options'] is List &&
                      questionObj['correct_answer'] is int &&
                      (questionObj['options'] as List).length == 4;
                })
                .cast<Map<String, dynamic>>()
                .toList();

            if (validQuizData.isEmpty) {
              return _parseQuizManually(content);
            }

            _lastGeneratedQuiz = validQuizData.take(5).toList();
            return _lastGeneratedQuiz;
          } else {
            return _parseQuizManually(content);
          }
        } catch (e) {
          return _parseQuizManually(content);
        }
      } else {
        return [];
      }
    } catch (e) {
      return _parseQuizManually('');
    }
  }

  static List<Map<String, dynamic>> _parseQuizManually(String quizText) {
    final List<Map<String, dynamic>> quiz = [];
    final lines = quizText.split('\n');

    String currentQuestion = '';
    List<String> currentOptions = [];
    int? correctAnswer;

    for (final line in lines) {
      if (line.startsWith('Question')) {
        if (currentQuestion.isNotEmpty) {
          quiz.add({
            'question': currentQuestion.trim(),
            'options': List<String>.from(currentOptions),
            'correct_answer': correctAnswer ?? 0,
          });
        }
        currentQuestion = line.replaceFirst('Question ', '').trim();
        currentOptions = [];
        correctAnswer = null;
      } else if (line.startsWith('Correct Answer')) {
        final answerStr = line.replaceFirst('Correct Answer: ', '').trim();
        correctAnswer = answerStr == 'A'
            ? 0
            : answerStr == 'B'
            ? 1
            : answerStr == 'C'
            ? 2
            : 3;
      } else if (line.startsWith(RegExp(r'^[A-D]\)'))) {
        currentOptions.add(line.substring(3).trim());
      }
    }

    // Add the last question if exists
    if (currentQuestion.isNotEmpty) {
      quiz.add({
        'question': currentQuestion.trim(),
        'options': List<String>.from(currentOptions),
        'correct_answer': correctAnswer ?? 0,
      });
    }

    _lastGeneratedQuiz = quiz.take(5).toList();
    return _lastGeneratedQuiz;
  }

  static List<Map<String, dynamic>> get lastGeneratedQuiz => _lastGeneratedQuiz;
}
