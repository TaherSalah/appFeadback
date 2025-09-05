class SearchResultModal {
  Ahadith ahadith;

  SearchResultModal({
    required this.ahadith,
  });

  factory SearchResultModal.fromJson(Map<String, dynamic> json) =>
      SearchResultModal(
        ahadith: Ahadith.fromJson(json["ahadith"]),
      );

  Map<String, dynamic> toJson() => {
        "ahadith": ahadith.toJson(),
      };
}

class Ahadith {
  String result;

  Ahadith({
    required this.result,
  });

  factory Ahadith.fromJson(Map<String, dynamic> json) => Ahadith(
        result: json["result"],
      );

  Map<String, dynamic> toJson() => {
        "result": result,
      };
}
