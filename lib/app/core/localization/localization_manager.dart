import 'language_ar.dart';
import 'language_en.dart';

class LocalizationManager {
  static bool isEn = true;
  // static bool isEn = false;

  static String call(String text) {
    if (isEn) {
      return textsEn[text]!;
    } else {
      return textsAr[text]!;
    }
  }

  static void change() {
    isEn = !isEn;
  }
}
