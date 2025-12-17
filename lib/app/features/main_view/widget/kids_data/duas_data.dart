class DuaForKids {
  final String id;
  final String title;
  final String arabic;
  final String meaning;
  final String emoji;

  DuaForKids({
    required this.id,
    required this.title,
    required this.arabic,
    required this.meaning,
    required this.emoji,
  });
}

class DuasData {
  static final List<DuaForKids> allDuas = [
    DuaForKids(
      id: 'morning',
      title: 'دعاء الصباح',
      emoji: '🌅',
      arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
      meaning: 'أصبحنا في هذا الصباح والملك كله لله',
    ),
    DuaForKids(
      id: 'evening',
      title: 'دعاء المساء',
      emoji: '🌙',
      arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
      meaning: 'أمسينا في هذا المساء والملك كله لله',
    ),
    DuaForKids(
      id: 'eating',
      title: 'دعاء الأكل',
      emoji: '🍽️',
      arabic: 'بِسْمِ اللَّهِ',
      meaning: 'أبدأ طعامي باسم الله',
    ),
    DuaForKids(
      id: 'after_eating',
      title: 'بعد الأكل',
      emoji: '✨',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا',
      meaning: 'الحمد لله الذي أعطانا طعاماً وشراباً',
    ),
    DuaForKids(
      id: 'sleep',
      title: 'دعاء النوم',
      emoji: '🛏️',
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      meaning: 'باسمك يا الله أنام وأستيقظ',
    ),
    DuaForKids(
      id: 'wakeup',
      title: 'دعاء الاستيقاظ',
      emoji: '☀️',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا',
      meaning: 'الحمد لله الذي أيقظنا بعد النوم',
    ),
    DuaForKids(
      id: 'entering_home',
      title: 'دخول المنزل',
      emoji: '🏠',
      arabic: 'بِسْمِ اللَّهِ وَلَجْنَا وَبِسْمِ اللَّهِ خَرَجْنَا',
      meaning: 'ندخل ونخرج من بيتنا باسم الله',
    ),
    DuaForKids(
      id: 'going_out',
      title: 'الخروج من المنزل',
      emoji: '🚶',
      arabic: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ',
      meaning: 'باسم الله أخرج وأتوكل على الله',
    ),
    DuaForKids(
      id: 'bathroom',
      title: 'دخول الحمام',
      emoji: '🚽',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
      meaning: 'أستعيذ بالله من الشياطين',
    ),
    DuaForKids(
      id: 'rain',
      title: 'دعاء المطر',
      emoji: '🌧️',
      arabic: 'اللَّهُمَّ صَيِّباً نَافِعاً',
      meaning: 'اللهم اجعل المطر نافعاً لنا',
    ),
  ];
}
