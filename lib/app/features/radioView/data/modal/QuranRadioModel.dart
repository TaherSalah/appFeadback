
class QuranRadioModel {
  List<Radio> radios;

  QuranRadioModel({
    required this.radios,
  });

  factory QuranRadioModel.fromJson(Map<String, dynamic> json) => QuranRadioModel(
    radios: List<Radio>.from(json["radios"].map((x) => Radio.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "radios": List<dynamic>.from(radios.map((x) => x.toJson())),
  };
}

class Radio {
  int id;
  String name;
  String url;
  dynamic recentDate;

  Radio({
    required this.id,
    required this.name,
    required this.url,
    required this.recentDate,
  });

  factory Radio.fromJson(Map<String, dynamic> json) => Radio(
    id: json["id"],
    name: json["name"],
    url: json["url"],
    // recentDate: DateTime.parse(json["recent_date"]),
    recentDate: json["recent_date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "url": url,
    "recent_date": recentDate.toIso8601String(),
  };
}
