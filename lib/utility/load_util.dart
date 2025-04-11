import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AssetDataLoader {
  /// Copies all files from `assets/data/` to the ApplicationDocumentsDirectory
  /// if they don't already exist.
  static Future<void> ensureAssetsInDocuments() async {
    // Load the AssetManifest.json to get a list of all assets
    final String manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = Map<String, dynamic>.from(json.decode(manifestContent));

    // Filter the assets to include only those in the `assets/data/` directory
    final List<String> assetFiles = manifestMap.keys
        .where((String key) => key.startsWith('assets/data/'))
        .toList();

    // Get the ApplicationDocumentsDirectory
    final directory = await getApplicationDocumentsDirectory();

    for (String assetPath in assetFiles) {
      // Extract the file name from the asset path
      final String fileName = assetPath.split('/').last;

      // Create the file path in the documents directory
      final File file = File('${directory.path}/$fileName');

      // Check if the file already exists
      if (!await file.exists()) {
        // If the file doesn't exist, copy it from assets
        final String assetData = await rootBundle.loadString(assetPath);
        await file.writeAsString(assetData);
        print('Copied $fileName to ${directory.path}');
      } else {
        print('$fileName already exists in ${directory.path}');
      }
    }
  }
}