import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;


class DeepAiService {

  DeepAiService() {
    init();
  }

  Future<void> init() async {
    _loadApiKey();
  }

  void _loadApiKey() async {
    final config = await rootBundle.loadString('assets/config.json');
    final configData = jsonDecode(config);
    apiKey = configData['deep_ai_api_key'];
  }

  late String apiKey;

  Future<String> generateEmail(String prompt) async {
    Uri url = Uri.parse('https://api.deepai.org/api/text-generator');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': prompt,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['output'] ?? 'No output';
    } else {
      throw Exception('Failed to generate email: ${response.statusCode}');
    }
  }
}