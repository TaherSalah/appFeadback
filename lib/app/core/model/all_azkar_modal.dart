import 'dart:convert';

AllAzkarModel allAzkarModelFromJson(String str) =>
    AllAzkarModel.fromJson(json.decode(str));

String allAzkarModelToJson(AllAzkarModel data) => json.encode(data.toJson());

class AllAzkarModel {
  List<Empty>? empty;

  AllAzkarModel({
    this.empty,
  });

  factory AllAzkarModel.fromJson(Map<String, dynamic> json) => AllAzkarModel(
        empty: List<Empty>.from(
            json["أذكار الصباح والمساء"].map((x) => Empty.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "أذكار الصباح والمساء":
            List<dynamic>.from(empty!.map((x) => x.toJson())),
      };
}

class Empty {
  int id;
  String arabicText;
  String languageArabicTranslatedText;
  String translatedText;
  int repeat;
  String audio;

  Empty({
    required this.id,
    required this.arabicText,
    required this.languageArabicTranslatedText,
    required this.translatedText,
    required this.repeat,
    required this.audio,
  });

  factory Empty.fromJson(Map<String, dynamic> json) => Empty(
        id: json["ID"],
        arabicText: json["ARABIC_TEXT"],
        languageArabicTranslatedText: json["LANGUAGE_ARABIC_TRANSLATED_TEXT"],
        translatedText: json["TRANSLATED_TEXT"],
        repeat: json["REPEAT"],
        audio: json["AUDIO"],
      );

  Map<String, dynamic> toJson() => {
        "ID": id,
        "ARABIC_TEXT": arabicText,
        "LANGUAGE_ARABIC_TRANSLATED_TEXT": languageArabicTranslatedText,
        "TRANSLATED_TEXT": translatedText,
        "REPEAT": repeat,
        "AUDIO": audio,
      };
}

