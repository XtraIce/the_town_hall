import 'dart:convert';
import 'package:http/http.dart' as http;

class WikiFetch {
  final String apiUrl = 'https://en.wikipedia.org/w/api.php';

  Future<String> fetchWikiSummary(String query) async {
    final response = await http.get(Uri.parse('$apiUrl?action=query&format=json&list=search&srsearch=$query'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['query']['search'].isNotEmpty) {
        return data['query']['search'][0]['snippet'];
      } else {
        return 'No results found.';
      }
    } else {
      throw Exception('Failed to load summary');
    }
  }

  Future<String> fetchPageImage(String pageId) async {
    final response = await http.get(Uri.parse('$apiUrl?action=query&format=json&prop=pageimages&pageids=$pageId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['query']['pages'][pageId]['thumbnail'] != null) {
        return data['query']['pages'][pageId]['thumbnail']['source'];
      } else {
        return 'No image found.';
      }
    } else {
      throw Exception('Failed to load image');
    }
  }
}