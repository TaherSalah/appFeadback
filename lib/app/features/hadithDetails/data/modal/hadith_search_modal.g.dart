// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_search_modal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResultModal _$SearchResultModalFromJson(Map<String, dynamic> json) =>
    SearchResultModal(
      ahadith: Ahadith.fromJson(json['ahadith'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchResultModalToJson(SearchResultModal instance) =>
    <String, dynamic>{
      'ahadith': instance.ahadith,
    };

Ahadith _$AhadithFromJson(Map<String, dynamic> json) => Ahadith(
      result: json['result'] as String,
    );

Map<String, dynamic> _$AhadithToJson(Ahadith instance) => <String, dynamic>{
      'result': instance.result,
    };
