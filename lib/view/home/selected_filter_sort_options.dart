import 'dart:convert';

class SelectedFilterSortOptions {
  int? sortValue;
  Map<String, String>? filterValues;

  SelectedFilterSortOptions({
    required this.filterValues,
    required this.sortValue,
  });

  void updateFilter(String filterName, String filterValue) {
    // Remove the entry if it exists with the same value
    if ((filterValues?.containsKey(filterName) ?? false) &&
        filterValues?[filterName] == filterValue) {
      filterValues?.remove(filterName);
    } else {
      filterValues?[filterName] = filterValue;
    }
  }

  void updateFilterMap(Map<String, String> newFilterMap) {
    clear();
    filterValues?.addAll(newFilterMap);
  }

  void updateSortValue(int? newValue) {
    if (sortValue == newValue) {
      sortValue = null;
    } else {
      sortValue = newValue;
    }
  }

  void clear() {
    filterValues?.clear();
    sortValue = null;
  }

  bool get isEmpty => (filterValues?.isEmpty ?? true) && sortValue == null;

  String get toJsonString {
    final jsonMap = {'sortValue': sortValue, 'filterValues': filterValues};
    return jsonEncode(jsonMap);
  }

  int get length {
    int length = 0;
    length = filterValues?.length ?? 0;
    if (sortValue != null) {
      length++;
    }
    return length;
  }

  Map<String, String> toMap() {
    return {
      ...sortValue != null ? {'sortValue': sortValue?.toString() ?? ''} : {},
      ...filterValues ?? {},
    };
  }
}
