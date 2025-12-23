class KidsHadith {
  final String id;
  final String title;
  final String hadith;
  final String meaning;
  final String emoji;

  KidsHadith({
    required this.id,
    required this.title,
    required this.hadith,
    required this.meaning,
    required this.emoji,
  });
}

class HadithsData {
  static final List<KidsHadith> allHadiths = [
    KidsHadith(
      id: 'smile',
      title: 'الابتسامة صدقة',
      emoji: '😊',
      hadith: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ صَدَقَةٌ',
      meaning: 'ابتسامتك في وجه أخيك تعتبر صدقة!',
    ),
    KidsHadith(
      id: 'mercy',
      title: 'الرحمة',
      emoji: '❤️',
      hadith: 'ارْحَمُوا مَنْ فِي الأَرْضِ يَرْحَمْكُمْ مَنْ فِي السَّمَاءِ',
      meaning: 'كن رحيماً مع الناس والحيوانات، يرحمك الله.',
    ),
    KidsHadith(
      id: 'neighbor',
      title: 'الجار',
      emoji: '🏘️',
      hadith:
          'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيُحْسِنْ إِلَى جَارِهِ',
      meaning: 'أحسن إلى جيرانك ولا تؤذهم.',
    ),
    KidsHadith(
      id: 'cleanliness',
      title: 'النظافة',
      emoji: '🧼',
      hadith: 'النَّظَافَةُ مِنَ الإِيمَانِ',
      meaning: 'كن نظيفاً في جسمك وملابسك ومكانك.',
    ),
    KidsHadith(
      id: 'truthful',
      title: 'الصدق',
      emoji: '✅',
      hadith: 'عَلَيْكُمْ بِالصِّدْقِ فَإِنَّ الصِّدْقَ يَهْدِي إِلَى الْبِرِّ',
      meaning: 'قل الصدق دائماً، فالصدق طريق الخير.',
    ),
    KidsHadith(
      id: 'kind_words',
      title: 'الكلمة الطيبة',
      emoji: '💬',
      hadith: 'الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ',
      meaning: 'كلامك الحلو والطيب يعتبر صدقة.',
    ),
    KidsHadith(
      id: 'help',
      title: 'مساعدة الآخرين',
      emoji: '🤝',
      hadith:
          'وَاللَّهُ فِي عَوْنِ الْعَبْدِ مَا كَانَ الْعَبْدُ فِي عَوْنِ أَخِيهِ',
      meaning: 'ساعد الناس، يساعدك الله في كل أمورك.',
    ),
    KidsHadith(
      id: 'parents',
      title: 'بر الوالدين',
      emoji: '👨‍👩‍👧',
      hadith: 'رِضَا اللَّهِ فِي رِضَا الْوَالِدَيْنِ',
      meaning: 'أطع والديك وأحسن إليهما، يرضى الله عنك.',
    ),
  ];
}
