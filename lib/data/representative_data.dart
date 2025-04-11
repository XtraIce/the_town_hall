import 'package:the_town_hall/models/representative_card.dart';
import 'package:the_town_hall/utility/json_util.dart';

class RepresentativeDataManager {
  RepresentativeDataManager._privateConstructor();

  static final RepresentativeDataManager _instance =
      RepresentativeDataManager._privateConstructor();

  factory RepresentativeDataManager() {
    return _instance;
  }

  final List<Representative> _representatives = [];

  /// Loads the representatives data from a JSON file and initializes the in-memory list.
  Future<void> initRepresentatives() async {
    if (_representatives.isNotEmpty) return;

    final List<dynamic> data = await JsonUtil.loadJsonList(
      'representatives.json',
    );
    _representatives.addAll(
      data.map((json) => Representative.fromJson(json)).toList(),
    );
  }

  /// Updates a representative's data both in-memory and in the JSON file.
  Future<void> updateRepresentative(
    int id,
    Map<String, dynamic> updatedData,
  ) async {
    final int index = _findRepresentativeIndexById(id);
    if (index == -1) throw Exception('Representative with id $id not found');

    // Update in-memory data
    _representatives[index] = Representative.fromJson(updatedData);

    // Update JSON file
    final List<dynamic> data = await JsonUtil.loadJsonList(
      'representatives.json',
    );
    final int jsonIndex = data.indexWhere((rep) => rep['id'] == id);
    if (jsonIndex == -1)
    {
      throw Exception('Representative with id $id not found in JSON file');
    }

    data[jsonIndex] = updatedData;
    await JsonUtil.saveJsonList('representatives.json', data);
  }

  /// Finds the index of a representative by ID in the in-memory list.
  int _findRepresentativeIndexById(int id) {
    return _representatives.indexWhere((rep) => rep.id == id);
  }

  /// Exposes the in-memory list of representatives.
  List<Representative> get representatives =>
      List.unmodifiable(_representatives);
}

// Access the singleton instance using:
final RepresentativeDataManager gRepresentativeDataManager =
    RepresentativeDataManager();
