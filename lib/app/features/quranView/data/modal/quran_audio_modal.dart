import 'package:freezed_annotation/freezed_annotation.dart';

part "quran_audio_modal.g.dart";

@JsonSerializable()
class QuranAudioModal {
  @JsonKey(name: "reciters")
  List<Reciter> reciters;

  QuranAudioModal({
    required this.reciters,
  });

  factory QuranAudioModal.fromJson(Map<String, dynamic> json) => _$QuranAudioModalFromJson(json);

  Map<String, dynamic> toJson() => _$QuranAudioModalToJson(this);
}

@JsonSerializable()
class Reciter {
  @JsonKey(name: "reciter_id")
  String reciterId;
  @JsonKey(name: "reciter_name")
  String reciterName;

  Reciter({
    required this.reciterId,
    required this.reciterName,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) => _$ReciterFromJson(json);

  Map<String, dynamic> toJson() => _$ReciterToJson(this);
}

