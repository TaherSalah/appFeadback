import 'package:objectbox/objectbox.dart' show Entity, Id, ToOne;
import 'collection_model.dart';

@Entity()
class BookObjModel {
  @Id()
  int? id;

  String bookName;
  String bookNumber;
  final ToOne<Collection> collection = ToOne<Collection>();

  BookObjModel({required this.bookName, required this.bookNumber});

  factory BookObjModel.fromJson(Map<String, dynamic> json) {
    return BookObjModel(
      bookNumber: json['book_number'],
      bookName: json['book_name'],
    );
  }
}
