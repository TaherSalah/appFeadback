enum UserGuideCategory {
  worship,
  finances,
  kids,
  companion,
  utilities,
  support,
}

class UserGuideItem {
  final String id;
  final String title;
  final String description;
  final String details;
  final String iconPath;
  final bool requiresInternet;
  final String? routeName;
  final List<String>? images;
  final UserGuideCategory category;
  final String? videoUrl;
  final bool isNew;
  final List<String>? steps;

  const UserGuideItem({
    required this.id,
    required this.title,
    required this.description,
    required this.details,
    required this.iconPath,
    required this.requiresInternet,
    required this.category,
    this.routeName,
    this.images,
    this.videoUrl,
    this.isNew = false,
    this.steps,
  });
}
