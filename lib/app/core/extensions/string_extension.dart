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

  String get normalizeArabic {
    if (isEmpty) return this;
    String normalized = replaceAll(RegExp(r'[أإآ]'), 'ا');
    normalized = normalized.replaceAll('ة', 'ه');
    normalized = normalized.replaceAll('ى', 'ي');
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
    return normalized.trim();
  }
}

extension StringNullExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}
