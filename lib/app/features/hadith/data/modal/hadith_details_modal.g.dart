// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_details_modal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HadithDetailsModal _$HadithDetailsModalFromJson(Map<String, dynamic> json) =>
    HadithDetailsModal(
      id: json['id'],
      title: json['title'],
      hadeeth: json['hadeeth'],
      attribution: json['attribution'],
      grade: json['grade'],
      explanation: json['explanation'],
      hints: json['hints'] as List<dynamic>?,
      categories: json['categories'] as List<dynamic>?,
      translations: json['translations'] as List<dynamic>?,
      hadeethIntro: json['hadeeth_intro'],
      wordsMeanings: (json['words_meanings'] as List<dynamic>?)
          ?.map((e) => WordsMeaning.fromJson(e as Map<String, dynamic>))
          .toList(),
      reference: json['reference'],
    );

Map<String, dynamic> _$HadithDetailsModalToJson(HadithDetailsModal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'hadeeth': instance.hadeeth,
      'attribution': instance.attribution,
      'grade': instance.grade,
      'explanation': instance.explanation,
      'hints': instance.hints,
      'categories': instance.categories,
      'translations': instance.translations,
      'hadeeth_intro': instance.hadeethIntro,
      'words_meanings': instance.wordsMeanings,
      'reference': instance.reference,
    };

WordsMeaning _$WordsMeaningFromJson(Map<String, dynamic> json) => WordsMeaning(
      word: json['word'],
      meaning: json['meaning'],
    );

