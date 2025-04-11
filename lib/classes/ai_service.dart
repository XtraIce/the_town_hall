import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;


class AiService {

  AiService();

  Future<void> init() async {
    await _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final config = await rootBundle.loadString('assets/configs/ai_config.json');
    final configData = jsonDecode(config);
    apiKey = configData['deepseek_api_key'];
    apiUrl = configData['deepseek_api_url'];
    // Ensure the API key is loaded correctly
    if (apiKey.isEmpty) {
      throw Exception('API key is empty in config file');
    }
    if(apiUrl.isEmpty) {
      throw Exception('API URL is empty in config file');
    }
  }

  late String apiKey;
  late String apiUrl;

  Future<String> generateEmail(String prompt) async {
    Uri url = Uri.parse(apiUrl);
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'deepseek-chat',
        'messages': [
          {
            'role': 'system',
            'content': 'You are a concerned citizen who wants to write a professional email to a representative.'
                       'Your response should be urgent and ready to  send.'
                       'No unnecessary information. Avoid contraction words and anything using apostrophes.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'stream': false,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Access the first choice in the choices array
      print('Response data: $data');
      final content = data['choices'][0]['message']['content'];
      return content ?? 'No output';
    } else {
      throw Exception('Failed to generate email: ${response.statusCode}');
    }
  }
}