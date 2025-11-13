class Dhikr {
  final String id;
  final String text;
  final int targetCount;
  int currentCount;

  Dhikr({
    required this.id,
    required this.text,
    required this.targetCount,
    this.currentCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'targetCount': targetCount,
    'currentCount': currentCount,
  };

  factory Dhikr.fromJson(Map<String, dynamic> json) => Dhikr(
    id: json['id'],
    text: json['text'],
    targetCount: json['targetCount'],
    currentCount: json['currentCount'] ?? 0,
  );
}
