class AppFeature {
  final String title;
  final String description;
  final String imagePath;
  final String? version; // إضافة (اختياري)

  AppFeature({
    required this.title,
    required this.description,
    required this.imagePath,
    this.version,
  });
}

class AppUpdates {
  // ✅ ميزات التطبيق الجديدة (للمستخدمين الجدد)
  static final List<AppFeature> firstTimeFeatures = [
    AppFeature(
      title: 'واجهة جديدة',
      description:
          'تصميم عصري ومريح للعين مع تجربة استخدام سلسة وانتقالات سلسة بين الشاشات',
      imagePath: 'assets/images/1_12_11zon.webp',
    ),
    AppFeature(
      title: 'مصحف تفاعلي',
      description:
          'استمتع بتجربة قراءة القرآن الكريم مع خيارات البحث السريع، إضافة العلامات المرجعية، والانتقال السهل بين السور والصفحات',
      imagePath: 'assets/images/4_15_11zon.webp',
    ),
    AppFeature(
      title: 'إنشاء ختمات للقرآن الكريم',
      description:
          'نظّم ختمتك بسهولة مع تحديد الأهداف اليومية، تتبع التقدم، وتذكيرات لمساعدتك على إنهاء القرآن',
      imagePath: 'assets/images/17_8_11zon.webp',
    ),
    AppFeature(
      title: 'أذكار متنوعة',
      description:
          'مكتبة شاملة من أذكار الصباح والمساء، أذكار الصلاة، النوم، والمناسبات المختلفة مع عداد ذكي لتتبع التكرار',
      imagePath: 'assets/images/2_13_11zon.webp',
    ),
    AppFeature(
      title: 'مواقيت الصلاة',
      description:
          'احصل على مواقيت الصلاة الدقيقة حسب موقعك، مع تنبيهات قبل الأذان وإمكانية تحديد اتجاه القبلة بدقة',
      imagePath: 'assets/images/12_3_11zon.webp',
    ),
    AppFeature(
      title: 'تفسير القرآن الكريم',
      description:
          'اقرأ وافهم معاني الآيات من خلال تفاسير موثوقة لعلماء معتمدين مع إمكانية البحث والمقارنة بين التفاسير',
      imagePath: 'assets/images/7_18_11zon.webp',
    ),
    AppFeature(
      title: 'الاستماع للقرآن الكريم',
      description:
          'استمع للقرآن الكريم بصوت مشايخ مختارين مع إمكانية التكرار، التحميل للاستماع بدون إنترنت،',
      imagePath: 'assets/images/6_17_11zon.webp',
    ),
    AppFeature(
      title: 'الاستماع للأذكار والرقية الشرعية',
      description:
          ' يمكنك الاستماع للأذكار والرقية الشرعية، مع خاصية التشغيل بدون انترنت',
      imagePath: 'assets/images/3_14_11zon.webp',
    ),
    AppFeature(
      title: 'المسبحة الإلكترونية',
      description:
          'سبّح بسهولة مع عداد إلكتروني ذكي يحفظ تسبيحاتك، وإحصائيات يومية',
      imagePath: 'assets/images/19_10_11zon.webp',
    ),
    AppFeature(
      title: 'تغيير حجم الخط والوضع الليلي للتطبيق',
      description:
          'خصّص تجربتك بتعديل حجم الخط حسب راحتك، مع وضع ليلي مريح للعين للقراءة في الإضاءة الخافتة',
      imagePath: 'assets/images/9_20_11zon.webp',
    ),
    AppFeature(
      title: 'إنشاء ورد من الأذكار اليومية المفضلة',
      description:
          'اختر أذكارك المفضلة وأنشئ وردك الخاص، مع جدولة التذكيرات وتتبع الالتزام اليومي',
      imagePath: 'assets/images/14_5_11zon.webp',
    ),
    AppFeature(
      title: 'لوحة تحكم احترافية لتتبع الورد اليومي',
      description:
          'راقب تقدمك بإحصائيات تفصيلية، رسوم بيانية توضح مدى التزامك، وتحفيزات لمواصلة أورادك اليومية',
      imagePath: 'assets/images/13_4_11zon.webp',
    ),
    AppFeature(
      title: 'إمكانية مشاركة ونسخ الذكر أو الأحاديث',
      description:
          'شارك الفائدة مع الآخرين بسهولة عبر نسخ النصوص أو مشاركتها مباشرة على وسائل التواصل الاجتماعي',
      imagePath: 'assets/images/11_2_11zon.webp',
    ),
    AppFeature(
      title: 'إذاعة القرآن الكريم وعلومه',
      description:
          'استمع لبث مباشر من إذاعة القرآن الكريم، مع برامج متنوعة في التفسير والفقه وعلوم القرآن',
      imagePath: 'assets/images/18_9_11zon.webp',
    ),
  ];

  // ✅ ميزات التحديث (للمستخدمين الحاليين)
  static final List<AppFeature> updateFeatures = [
    AppFeature(
      title: 'نظام أذان متطور',
      description:
      'إصلاح شامل لنظام الأذان وجدولة التنبيهات لضمان العمل بدقة عالية في مواعيدها حتى في وضع السكون.',
      imagePath: 'assets/images/12_3_11zon.webp',
    ),
    AppFeature(
      title: 'التمرير التلقائي والقارئ علي جابر',
      description:
      'إضافة ميزة التمرير التلقائي في المصحف، وإضافة تلاوات الشيخ علي جابر رحمه الله.',
      imagePath: 'assets/images/6_17_11zon.webp',
    ),
    AppFeature(
      title: 'تذكيرات الختمة الذكية',
      description:
      'نظام ذكي لمتابعة الختمات والتنبيه بمواعيد القراءة اليومية لضمان ختم القرآن.',
      imagePath: 'assets/images/17_8_11zon.webp',
    ),
    AppFeature(
      title: 'تنبيهات الأوراد والأذكار',
      description:
      'إشعارات ذكية في حال نسيان الورد القرآني أو أذكار الصباح والمساء.',
      imagePath: 'assets/images/14_5_11zon.webp',
    ),
  ];
  // ✅ يمكنك تحديث القائمة هنا مع كل إصدار جديد
  static List<AppFeature> getFeaturesForVersion(String version) {
    // يمكنك إضافة منطق لإرجاع ميزات معينة حسب الإصدار
    return updateFeatures;
  }
}
