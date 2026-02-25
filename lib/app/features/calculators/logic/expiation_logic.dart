enum ExpiationType {
  oath, // كفارة يمين
  fasting, // فدية صيام (للمريض أو الكبير)
  intentionalFasting, // كفارة إفطار عمد في رمضان (60 مسكيناً)
}

class ExpiationCalculator {
  static double calculate({
    required ExpiationType type,
    required double mealPrice,
    int quantity =
        1, // Number of times (e.g., number of oaths or number of days missed)
  }) {
    int peopleCount = 0;

    switch (type) {
      case ExpiationType.oath:
        peopleCount = 10;
        break;
      case ExpiationType.fasting:
        peopleCount = 1;
        break;
      case ExpiationType.intentionalFasting:
        peopleCount = 60;
        break;
    }

    return peopleCount * mealPrice * quantity;
  }

  static String getDescription(ExpiationType type) {
    switch (type) {
      case ExpiationType.oath:
        return "إطعام عشرة مساكين من أوسط ما تطعمون أهليكم";
      case ExpiationType.fasting:
        return "إطعام مسكين واحد عن كل يوم";
      case ExpiationType.intentionalFasting:
        return "إطعام ستين مسكيناً";
    }
  }
}
