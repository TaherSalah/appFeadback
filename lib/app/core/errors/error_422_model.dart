import 'package:flutter/foundation.dart';

class Error422Model {
  String error;
  Map<String, List> errors;

  Error422Model({this.error = "", required this.errors});

  factory Error422Model.fromJson(Map<String, dynamic> map) {
    return Error422Model(
      error: map['error'] ?? "",
      errors: Map<String, List>.from(map['errors'] ?? {}),
    );
  }

  bool get hasSingleError => error.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;

  String get errorMessageWithoutQuotesAndKey {
    // Extract the error message using a regular expression.
    RegExp exp = RegExp(r'"error"\s*:\s*"(.+?)"');
    Match? match = exp.firstMatch(error);
    return match?.group(1) ?? "";
  }

  @override
  bool operator ==(covariant Error422Model other) {
    if (identical(this, other)) return true;

    return error == other.error && mapEquals(other.errors, errors);
  }

  @override
  int get hashCode => error.hashCode ^ errors.hashCode;
}
