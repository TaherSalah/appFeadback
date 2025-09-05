import 'dart:convert';

import 'package:flutter/services.dart';

import 'VerseModel.dart';

class SurahModel {
  final int id;
  final String name;
  final String transliteration;
  final String type;
  final int totalVerses;
  final List<VerseModel> verses;

  SurahModel({
    required this.id,
    required this.name,
    required this.transliteration,
    required this.type,
    required this.totalVerses,
    required this.verses,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    var versesList = (json['verses'] as List)
        .map((v) => VerseModel.fromJson(v))
        .toList();

    return SurahModel(
      id: json['id'],
      name: json['name'],
      transliteration: json['transliteration'],
      type: json['type'],
      totalVerses: json['total_verses'],
      verses: versesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'transliteration': transliteration,
      'type': type,
      'total_verses': totalVerses,
      'verses': verses.map((v) => v.toJson()).toList(), // شغال تمام دلوقتي
    };
  }


}
Future<List<SurahModel>> loadQuranFromAssets() async {
  final String response = await rootBundle.loadString('assets/json/quran.json');
  final List data = jsonDecode(response);

  return data.map((suraJson) => SurahModel.fromJson(suraJson)).toList();
}
