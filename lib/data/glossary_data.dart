import 'package:the_town_hall/utility/json_util.dart';
import 'package:the_town_hall/models/glossary.dart';

class GlossaryManager {
  /// Private constructor for singleton
  GlossaryManager._privateConstructor();

  /// The single instance of GlossaryManager
  static final GlossaryManager _instance = GlossaryManager._privateConstructor();

  /// Factory constructor to return the singleton instance
  factory GlossaryManager() {
    return _instance;
  }

  /// Singleton instance of the glossary data.
  final Glossary glossaryData = Glossary(entries: []);

  /// Initializes the glossary by loading data from the JSON file.
  Future<void> initGlossary() async {
    if (glossaryData.entries.isNotEmpty) return;

    final List<dynamic> data = await JsonUtil.loadJsonList('glossary.json');
    final entries = data.map((json) => GlossaryEntry.fromJson(json)).toList();
    glossaryData.entries.addAll(entries);
  }

  /// Updates a glossary entry in both in-memory data and the JSON file.
  Future<void> updateGlossaryEntry(String term, Map<String, dynamic> updatedData) async {
    final int index = _findGlossaryEntryIndexByTerm(term);
    if (index == -1) throw Exception('Glossary entry with term "$term" not found');

    // Update in-memory data
    glossaryData.entries[index] = GlossaryEntry.fromJson(updatedData);

    // Update JSON file
    await JsonUtil.updateJsonEntry(
      'glossary.json',
      'term',
      term,
      updatedData,
    );
  }

  /// Finds the index of a glossary entry by term in the in-memory list.
  int _findGlossaryEntryIndexByTerm(String term) {
    return glossaryData.entries.indexWhere((entry) => entry.term == term);
  }
}

// Access the singleton instance
final GlossaryManager gGlossaryManager = GlossaryManager();
