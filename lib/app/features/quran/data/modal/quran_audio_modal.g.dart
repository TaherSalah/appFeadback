// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quran_audio_modal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuranAudioModal _$QuranAudioModalFromJson(Map<String, dynamic> json) =>
    QuranAudioModal(
      reciters: (json['reciters'] as List<dynamic>)
          .map((e) => Reciter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuranAudioModalToJson(QuranAudioModal instance) =>
    <String, dynamic>{
      'reciters': instance.reciters,
    };

Reciter _$ReciterFromJson(Map<String, dynamic> json) => Reciter(
      reciterId: json['reciter_id'] as String,
      reciterName: json['reciter_name'] as String,
    );

Map<String, dynamic> _$ReciterToJson(Reciter instance) => <String, dynamic>{
      'reciter_id': instance.reciterId,
      'reciter_name': instance.reciterName,
    };
