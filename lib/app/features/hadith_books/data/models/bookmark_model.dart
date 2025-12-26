import 'package:objectbox/objectbox.dart' show Entity, Id, ToOne;
import 'ar_hadith_model.dart';

@Entity()
class BookmarkModel {
  @Id()
  int? id;
  
  final String category; // التصنيف: أخلاق، عبادات، فضائل، etc.
  final String? note; // ملاحظة شخصية اختيارية
  final DateTime createdAt; // تاريخ الحفظ
  
  // Relation to ARHadithModel
  final ToOne<ARHadithModel> hadith = ToOne<ARHadithModel>();

  BookmarkModel({
    this.id,
    required this.category,
    this.note,
    required this.createdAt,
  });
}
