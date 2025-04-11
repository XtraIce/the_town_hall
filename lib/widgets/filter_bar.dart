import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget {
  final Map<String, bool> filters;
  final ValueChanged<Map<String, bool>> onFiltersChanged;

  const FilterBar({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  late Map<String, bool> filters;

  @override
  void initState() {
    super.initState();
    filters = Map<String, bool>.from(widget.filters);
  }

  String getSelectedFiltersText() {
    final selectedFilters = filters.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    return selectedFilters.isEmpty ? "Select filters" : selectedFilters.join(', ');
  }

  void updateFilter(String filter, bool value) {
    setState(() {
      filters[filter] = value;
    });
    widget.onFiltersChanged(filters); // Notify parent widget
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: null,
        hint: Text(getSelectedFiltersText()),
        items: filters.keys.map((filter) {
          return DropdownMenuItem<String>(
            value: filter,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      filter,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Checkbox(
                      value: filters[filter],
                      onChanged: (bool? value) {
                        setState(() {
                          filters[filter] = value ?? false;
                        });
                        updateFilter(filter, value ?? false); // Update parent state
                      },
                    ),
                  ],
                );
              },
            ),
          );
        }).toList(),
        onChanged: (_) {},
      ),
    );
  }
}
