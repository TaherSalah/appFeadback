// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_details_modal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuranDetailsModal _$QuranDetailsModalFromJson(Map<String, dynamic> json) =>
    QuranDetailsModal(
      reciterId: json['reciter_id'] as String,
      reciterName: json['reciter_name'] as String,
      audioUrls: (json['audio_urls'] as List<dynamic>)
          .map((e) => AudioUrl.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuranDetailsModalToJson(QuranDetailsModal instance) =>
    <String, dynamic>{
      'reciter_id': instance.reciterId,
      'reciter_name': instance.reciterName,
      'audio_urls': instance.audioUrls,
    };

AudioUrl _$AudioUrlFromJson(Map<String, dynamic> json) => AudioUrl(
      surahId: json['surah_id'] as String,
      surahNameAr: json['surah_name_ar'] as String,
      audioUrl: json['audio_url'] as String,
    );

Map<String, dynamic> _$AudioUrlToJson(AudioUrl instance) => <String, dynamic>{
      'surah_id': instance.surahId,
      'surah_name_ar': instance.surahNameAr,
      'audio_url': instance.audioUrl,
    };
