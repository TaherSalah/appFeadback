import 'package:json_annotation/json_annotation.dart';

part 'all_hadith_categories_modal.g.dart';

@JsonSerializable()
class AllHadithCategorieModal {
  List<Datum>? data;
  Meta? meta;

  AllHadithCategorieModal({
    this.data,
    this.meta,
  });

  factory AllHadithCategorieModal.fromJson(Map<String, dynamic> json) =>
      _$AllHadithCategorieModalFromJson(json);

  Map<String, dynamic> toJson() => _$AllHadithCategorieModalToJson(this);
}

@JsonSerializable()
class Datum {
  String? id;
  String? title;
  List<String>? translations;

  Datum({
    this.id,
    this.title,
    this.translations,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);

  Map<String, dynamic> toJson() => _$DatumToJson(this);
}

@JsonSerializable()
class Meta {
  @JsonKey(name: 'current_page')
  String? currentPage;
  @JsonKey(name: 'last_page')
  int? lastPage;
  @JsonKey(name: 'total_items')
  int? totalItems;
  @JsonKey(name: 'per_page')
  String? perPage;

  Meta({
    this.currentPage,
    this.lastPage,
    this.totalItems,
    this.perPage,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);

  Map<String, dynamic> toJson() => _$MetaToJson(this);
}
