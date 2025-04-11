import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class JsonUtil {
  /// Loads JSON data from the specified file path.
  /// If the file doesn't exist in the documents directory, it loads from assets.
  static Future<List<dynamic>> loadJsonList(String fileName, {String? assetPath}) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    if (await file.exists()) {
      // Load from the writable documents directory
      final String response = await file.readAsString();
      return json.decode(response);
    } else if (assetPath != null) {
      // Load from assets if the file doesn't exist in the documents directory
      final String response = await rootBundle.loadString(assetPath);
      return json.decode(response);
    } else {
      throw Exception('File $fileName not found in documents directory or assets.');
    }
  }

  /// Saves JSON data to the specified file in the documents directory.
  static Future<void> saveJsonList(String fileName, List<dynamic> data) async {
    final String jsonString = json.encode(data);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonString);
  }

  /// Updates a specific entry in the JSON file by matching a key-value pair.
  static Future<void> updateJsonEntry(
    String fileName,
    String key,
    dynamic value,
    Map<String, dynamic> updatedData,
  ) async {
    final List<dynamic> data = await loadJsonList(fileName);
    final int index = data.indexWhere((entry) => entry[key] == value);

    if (index == -1) {
      throw Exception('Entry with $key = $value not found in $fileName.');
    }

    data[index] = updatedData;
    await saveJsonList(fileName, data);
  }
}