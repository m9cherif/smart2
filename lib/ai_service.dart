import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

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
    try {
      if (!await pdfFile.exists()) {
        return 'PDF file not found.';
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://v2.convertapi.com/convert/pdf/to/txt'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer FnpOXR02fbG81U7WETCOUOn2824nsCuM',
      });

      request.fields['StoreFile'] = 'true';
      request.files.add(
        await http.MultipartFile.fromPath('File', pdfFile.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var json = jsonDecode(responseData);

        if (json['Files'] != null && json['Files'].isNotEmpty) {
          String fileUrl = json['Files'][0]['Url'];

          var textResponse = await http.get(Uri.parse(fileUrl));

          if (textResponse.statusCode == 200) {
            String extractedText = textResponse.body;
            return extractedText.isNotEmpty
                ? extractedText
                : 'No text content found in PDF';
          } else {
            return 'Error downloading extracted text: HTTP ${textResponse.statusCode}';
          }
        } else {
          return 'Error: No files returned from conversion API';
        }
      } else {
        var responseData = await response.stream.bytesToString();
        return 'Error converting PDF: HTTP ${response.statusCode}\n$responseData';
      }
    } catch (e) {
      return 'Error extracting text from PDF: ${e.toString()}';
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

  // Process PDF directly with AI (returns summary)
  static Future<String> processPDFWithAI(File pdfFile) async {
    try {
      // Extract text from PDF
      final extractedText = await extractTextFromPDF(pdfFile);

      // If no text found, return appropriate message
      if (extractedText.isEmpty ||
          extractedText == 'No text content found in PDF') {
        return 'No readable text could be extracted from this PDF. The document may contain scanned images or complex formatting that requires specialized processing.';
      }

      // Generate summary directly from extracted text
      return await generateSummary(extractedText);
    } catch (e) {
      return 'Error processing PDF with AI: ${e.toString()}';
    }
  }

  // Process PDF directly with AI (returns quiz)
  static Future<List<Map<String, dynamic>>> processPDFQuizWithAI(
    File pdfFile,
  ) async {
    try {
      // Extract text from PDF
      final extractedText = await extractTextFromPDF(pdfFile);

      // If no text found, return empty quiz
      if (extractedText.isEmpty ||
          extractedText == 'No text content found in PDF') {
        return [];
      }

      // Generate quiz directly from extracted text
      return await generateQuiz(extractedText);
    } catch (e) {
      return [];
    }
  }

  // Extract text from any file (PDF or text)
  static Future<String> extractTextFromFile(File file) async {
    if (file.path.toLowerCase().endsWith('.pdf')) {
      return await extractTextFromPDF(file);
    } else {
      return await extractTextFromTextFile(file);
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
