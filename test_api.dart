import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  final apiKey = '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';
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
      'HTTP-Referer': 'https://openrouter.ai/',
    },
    body: jsonEncode({
      'model': 'deepseek/deepseek-chat',
      'messages': [
        {
          'role': 'user',
          'content': 'Test'
        }
      ],
      'max_tokens': 100,
    }),
  );
  print(response.statusCode);
  print(response.body);
}
