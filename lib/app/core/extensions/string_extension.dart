extension StringExtension on String {
  // Safe parsing
  int? get toInt => int.tryParse(this);
  double? get toDouble => double.tryParse(this);

  // Capitalization
  String get capitalize => isNotEmpty
      ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}'
      : this;

  // Checking for numeric values
  bool get isNumeric => double.tryParse(this) != null;
}

extension StringNullExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}
