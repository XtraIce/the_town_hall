class Glossary {
  final List<GlossaryEntry> entries;

  Glossary({required this.entries});

  void addEntry(GlossaryEntry entry) {
    entries.add(entry);
  }

  @override
  String toString() {
    return entries.map((e) => e.toString()).join('\n');
  }
}

class GlossaryEntry {
  final String term;
  final String definition;
  final String? whatTheyDo;

  GlossaryEntry({
    required this.term,
    required this.definition,
    this.whatTheyDo,
  });

  factory GlossaryEntry.fromJson(Map<String, dynamic> json) {
    return GlossaryEntry(
      term: json['term'],
      definition: json['definition'],
      whatTheyDo: json['whatTheyDo'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'term': term,
      'definition': definition,
      'whatTheyDo': whatTheyDo,
    };
  }

  @override
  String toString() {
    return '$term: $definition';
  }
}