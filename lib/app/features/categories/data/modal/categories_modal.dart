import 'package:freezed_annotation/freezed_annotation.dart';

part "categories_modal.g.dart";

@JsonSerializable()
class CategoriesModal {
  String? id;
  String? title;
  @JsonKey(name: 'hadeeths_count')
  String? hadeethsCount;
  @JsonKey(name: 'parent_id')
  String? parentId;

  CategoriesModal({
    this.id,
    this.title,
    this.hadeethsCount,
    this.parentId,
  });

  factory CategoriesModal.fromJson(Map<String, dynamic> json) =>
      _$CategoriesModalFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesModalToJson(this);
}
