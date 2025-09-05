// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_modal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoriesModal _$CategoriesModalFromJson(Map<String, dynamic> json) =>
    CategoriesModal(
      id: json['id'] as String?,
      title: json['title'] as String?,
      hadeethsCount: json['hadeeths_count'] as String?,
      parentId: json['parent_id'] as String?,
    );

Map<String, dynamic> _$CategoriesModalToJson(CategoriesModal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'hadeeths_count': instance.hadeethsCount,
      'parent_id': instance.parentId,
    };
