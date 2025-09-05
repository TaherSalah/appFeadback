import 'package:freezed_annotation/freezed_annotation.dart';
part "quran_details_modal.g.dart";

@JsonSerializable()
class QuranDetailsModal {
  @JsonKey(name: "reciter_id")
  String reciterId;
  @JsonKey(name: "reciter_name")
  String reciterName;
  @JsonKey(name: "audio_urls")
  List<AudioUrl> audioUrls;

  QuranDetailsModal({
    required this.reciterId,
    required this.reciterName,
    required this.audioUrls,
  });

  factory QuranDetailsModal.fromJson(Map<String, dynamic> json) => _$QuranDetailsModalFromJson(json);

  Map<String, dynamic> toJson() => _$QuranDetailsModalToJson(this);
}

@JsonSerializable()
class AudioUrl {
  @JsonKey(name: "surah_id")
  String surahId;
  @JsonKey(name: "surah_name_ar")
  String surahNameAr;
  @JsonKey(name: "audio_url")
  String audioUrl;
  AudioUrl({
    required this.surahId,
    required this.surahNameAr,
    required this.audioUrl,
  });
  factory AudioUrl.fromJson(Map<String, dynamic> json) => _$AudioUrlFromJson(json);
  Map<String, dynamic> toJson() => _$AudioUrlToJson(this);
}
