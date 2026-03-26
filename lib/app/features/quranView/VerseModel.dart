class VerseModel {
  final String text;

  VerseModel({required this.text});

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}
