enum Gender { male, female }

class HeirsInput {
  final double totalEstate;
  final double debts;
  final List<String> willFractions;
  final bool heirsConsent;
  final Gender deceasedGender;

  // Primary
  final int wives;
  final bool hasHusband;
  final bool hasFather;
  final bool hasMother;
  final int sons;
  final int daughters;

  // Extended
  final int sonsOfSons;
  final int daughtersOfSons;
  final bool hasPaternalGrandfather;
  final bool hasMaternalGrandmother;
  final bool hasPaternalGrandmother;
  final int fullBrothers;
  final int fullSisters;
  final int consanguineBrothers;
  final int consanguineSisters;
  final int uterineBrothers;
  final int uterineSisters;
  final int nephewsFull;
  final int nephewsConsanguine;
  final int grandNephewsFull; // NEW: ابن ابن أخ شقيق
  final int grandNephewsConsanguine; // NEW: ابن ابن أخ لأب
  final int paternalUnclesFull;
  final int paternalUnclesConsanguine;
  final int cousinsFull;
  final int cousinsConsanguine;
  final int grandCousinsFull; // NEW: ابن ابن عم شقيق
  final int grandCousinsConsanguine; // NEW: ابن ابن عم لأب
  final int paternalGreatUnclesFull; // NEW: عم الأب شقيق
  final int paternalGreatUnclesConsanguine; // NEW: عم الأب لأب
  final int paternalGreatCousinsFull; // NEW: ابن عم الأب شقيق
  final int paternalGreatCousinsConsanguine; // NEW: ابن عم الأب لأب

  // Special Cases
  final bool isMunasaqhat;
  final bool hasObligatoryWill;
  final bool isPregnancy;
  final bool isHermaphrodite;
  final bool isMissingPerson;

  final String madhab;

  HeirsInput({
    required this.totalEstate,
    this.debts = 0,
    required this.deceasedGender,
    this.willFractions = const [],
    this.heirsConsent = false,
    this.madhab = "الجمهور",
    this.wives = 0,
    this.hasHusband = false,
    this.hasFather = false,
    this.hasMother = false,
    this.sons = 0,
    this.daughters = 0,
    this.sonsOfSons = 0,
    this.daughtersOfSons = 0,
    this.hasPaternalGrandfather = false,
    this.hasMaternalGrandmother = false,
    this.hasPaternalGrandmother = false,
    this.fullBrothers = 0,
    this.fullSisters = 0,
    this.consanguineBrothers = 0,
    this.consanguineSisters = 0,
    this.uterineBrothers = 0,
    this.uterineSisters = 0,
    this.nephewsFull = 0,
    this.nephewsConsanguine = 0,
    this.grandNephewsFull = 0,
    this.grandNephewsConsanguine = 0,
    this.paternalUnclesFull = 0,
    this.paternalUnclesConsanguine = 0,
    this.cousinsFull = 0,
    this.cousinsConsanguine = 0,
    this.grandCousinsFull = 0,
    this.grandCousinsConsanguine = 0,
    this.paternalGreatUnclesFull = 0,
    this.paternalGreatUnclesConsanguine = 0,
    this.paternalGreatCousinsFull = 0,
    this.paternalGreatCousinsConsanguine = 0,
    this.isMunasaqhat = false,
    this.hasObligatoryWill = false,
    this.isPregnancy = false,
    this.isHermaphrodite = false,
    this.isMissingPerson = false,
  });
}

class DetailedHeirShare {
  final String name;
  final double fraction; // 0 if Asabah
  final String fractionString; // "1/2", "1/8", or "بقية/عصبة"
  final double amount;
  final String description;
  final bool isAsabah;
  final int count;
  final int numerator;
  final int denominator;

  DetailedHeirShare({
    required this.name,
    this.fraction = 0,
    this.fractionString = "",
    required this.amount,
    required this.description,
    this.isAsabah = false,
    this.count = 1,
    this.numerator = 0,
    this.denominator = 0,
  });
}

class InheritanceEngine {
  static List<DetailedHeirShare> calculate(HeirsInput input) {
    // 1. Initial Financial Preparations
    double netEstate = input.totalEstate - input.debts;

    // Calculate total Wills from fractions
    double totalWillFraction = 0;
    for (var f in input.willFractions) {
      totalWillFraction += _fractionToDouble(f);
    }

    double calculatedWills = netEstate * totalWillFraction;

    // Sharia Rule: Wills cannot exceed 1/3 of net estate unless heirs consent
    if (!input.heirsConsent && totalWillFraction > (1 / 3)) {
      calculatedWills = netEstate * (1 / 3);
    }

    netEstate -= calculatedWills;

    if (netEstate <= 0) {
      return [
        DetailedHeirShare(
            name: "التركة استنفدت في الديون والوصايا",
            fractionString: "0",
            amount: 0,
            description: "لا يوجد باقٍ للورثة")
      ];
    }

    List<DetailedHeirShare> results = [];

    // --- Special Case: Obligatory Will (الوصية الواجبة) ---
    // Rule: Grandchildren of a child who died before the deceased take a share (Egypt, Jordan, etc.)
    bool lawSupportsObligatoryWill = [
      "قانون المواريث المصري",
      "الأحوال الشخصية الأردني",
      "قانون الأسرة الجزائري",
      "القانون الكويتي",
      "تونس، الصادر عام 1956م",
      "الأحوال الشخصية الإماراتي",
      "القانون العماني",
      "مدونة الأسرة المغربية"
    ].contains(input.madhab);

    if (lawSupportsObligatoryWill && input.hasObligatoryWill) {
      // Calculate share: parent's share (max 1/3 of net estate)
      // This is a complex secondary calculation, we'll implement a simplified 1/3 cap logic
      double obligatoryShare = netEstate * (1 / 3);
      results.add(DetailedHeirShare(
          name: "الوصية الواجبة (للأحفاد)",
          fractionString: "بحد أقصى 1/3",
          count: 1, // Treat as one group
          amount: obligatoryShare,
          description: "مقدار نصيب والديهم المتوفى (بحد أقصى الثلث)"));
      netEstate -= obligatoryShare;
    }

    // Existence flags for quick logic
    bool hasBranch = (input.sons +
            input.daughters +
            input.sonsOfSons +
            input.daughtersOfSons) >
        0;
    bool hasMaleBranch = (input.sons + input.sonsOfSons) > 0;
    bool hasSiblingsMultiple = (input.fullBrothers +
            input.fullSisters +
            input.consanguineBrothers +
            input.consanguineSisters +
            input.uterineBrothers +
            input.uterineSisters) >
        1;

    // --- II. Fixed Share Heirs (As'hab al-Furud) ---
    Map<String, double> fractions = {};
    Map<String, String> reasons = {};

    // 1. Husband
    if (input.hasHusband) {
      fractions["husband"] = hasBranch ? 1 / 4 : 1 / 2;
      reasons["husband"] =
          hasBranch ? "الربع لوجود فرع وارث" : "النصف لعدم وجود فرع وارث";
    }

    // 2. Wives
    if (input.wives > 0) {
      fractions["wives"] = hasBranch ? 1 / 8 : 1 / 4;
      reasons["wives"] =
          hasBranch ? "الثمن لوجود فرع وارث" : "الربع لعدم وجود فرع وارث";
    }

    // 3. Mother
    if (input.hasMother) {
      if (hasBranch || hasSiblingsMultiple) {
        fractions["mother"] = 1 / 6;
        reasons["mother"] = "السدس لوجود فرع وارث أو عدد من الإخوة";
      } else {
        fractions["mother"] = 1 / 3;
        reasons["mother"] = "الثلث لعدم وجود فرع وارث أو عدد من الإخوة";
      }
      // Special cases (Umriyatan) will be handled if father and spouse exist and no branch
    }

    // 4. Father (Fixed share part)
    if (input.hasFather) {
      if (hasBranch) {
        fractions["father"] = 1 / 6;
        reasons["father"] = "السدس لوجود فرع وارث";
      }
    }

    // --- Special: Umriyatan Cases (الغراوين) ---
    // If only (Husband/Wife + Mother + Father) exist and no branch/siblings
    if (!hasBranch && !hasSiblingsMultiple) {
      if (input.hasMother && input.hasFather) {
        if (input.hasHusband || input.wives > 0) {
          fractions["mother"] = 1 / 3; // Initially 1/3, but of the remainder
          reasons["mother"] = "ثلث الباقي (المسألة العمرية)";
          // In calculation we'll adjust: Mother gets 1/3 * (1 - Spouse share)
          double spouseShare = input.hasHusband ? (1 / 2) : (1 / 4);
          fractions["mother"] = (1 / 3) * (1 - spouseShare);
        }
      }
    }

    // 5. Grandparents (simplified)
    if (!input.hasFather && input.hasPaternalGrandfather) {
      if (hasBranch) {
        fractions["grandfather"] = 1 / 6;
        reasons["grandfather"] = "السدس لوجود فرع وارث وعدم وجود الأب";
      }
    }

    // 6. Grandmother
    if (!input.hasMother &&
        (input.hasMaternalGrandmother || input.hasPaternalGrandmother)) {
      fractions["grandmother"] = 1 / 6;
      reasons["grandmother"] = "السدس لعدم وجود الأم";
    }

    // 7. Daughters (Fixed share)
    if (input.sons == 0 && input.daughters > 0) {
      if (input.daughters == 1) {
        fractions["daughters"] = 1 / 2;
        reasons["daughters"] = "النصف لانفرادها وعدم وجود عاصب";
      } else {
        fractions["daughters"] = 2 / 3;
        reasons["daughters"] = "الثلثان لتعددهن وعدم وجود عاصب";
      }
    }

    // 8. Son's Daughters (Fixed share if no daughters/sons)
    if (input.sons == 0 &&
        input.daughters <= 1 &&
        input.sonsOfSons == 0 &&
        input.daughtersOfSons > 0) {
      if (input.daughters == 0) {
        if (input.daughtersOfSons == 1) {
          fractions["grand_daughters"] = 1 / 2;
          reasons["grand_daughters"] = "النصف لانفرادها وعدم وجود حاجب أو عاصب";
        } else {
          fractions["grand_daughters"] = 2 / 3;
          reasons["grand_daughters"] = "الثلثان لتعددهن وعدم وجود حاجب أو عاصب";
        }
      } else if (input.daughters == 1) {
        fractions["grand_daughters"] = 1 / 6;
        reasons["grand_daughters"] = "السدس تكملة للثلثين مع البنت الصلبية";
      }
    }

    // 9. Uterine Siblings (الإخوة لأم)
    if (!hasBranch && !input.hasFather && !input.hasPaternalGrandfather) {
      int uterineCount = input.uterineBrothers + input.uterineSisters;

      // --- Special: Al-Mushtaraka (المسألة المشتركة) Shafi'i/Maliki/Saudi ---
      bool isMushtaraka = (input.hasHusband &&
          input.hasMother &&
          (input.fullBrothers > 0) &&
          uterineCount > 0 &&
          !hasBranch &&
          !input.hasFather);

      if (isMushtaraka &&
          (input.madhab == "الشافعية" ||
              input.madhab == "المالكية" ||
              input.madhab == "نظام الأحوال الشخصية السعودي")) {
        fractions["uterine_plus_full"] = 1 / 3;
        reasons["uterine_plus_full"] =
            "الثلث يشارك فيه الإخوة الأشقاء مع الإخوة لأم (المشتركة)";
      } else {
        if (uterineCount == 1) {
          fractions["uterine"] = 1 / 6;
          reasons["uterine"] = "السدس لانفراده ولعدم وجود حاجب";
        } else if (uterineCount > 1) {
          fractions["uterine"] = 1 / 3;
          reasons["uterine"] = "الثلث لتعددهم ولعدم وجود حاجب";
        }
      }
    }

    // 10. Sisters (Fixed share logic)
    // Rule: Sisters get fixed shares if no male branch, no father, and no brothers
    if (!hasMaleBranch &&
        !input.hasFather &&
        input.sons == 0 &&
        input.daughters == 0 &&
        input.sonsOfSons == 0 &&
        input.daughtersOfSons == 0) {
      // Logic for Grandfather vs Sisters for Jumhur (He can share with them)
      bool grandfatherBlocksSisters = (input.madhab == "الأحناف");
      bool shouldCheckSisters =
          !grandfatherBlocksSisters || !input.hasPaternalGrandfather;

      if (shouldCheckSisters) {
        if (input.fullBrothers == 0 && input.fullSisters > 0) {
          if (input.fullSisters == 1) {
            fractions["full_sisters"] = 1 / 2;
            reasons["full_sisters"] = "النصف لانفرادها وعدم وجود عاصب أو حاجب";
          } else {
            fractions["full_sisters"] = 2 / 3;
            reasons["full_sisters"] = "الثلثان لتعددهن وعدم وجود عاصب أو حاجب";
          }
        }
      }
    }

    // --- III. Awl (Increase) & Radd (Return) ---
    double sumFractions = fractions.values.fold(0, (sum, val) => sum + val);

    // Awl Check
    if (sumFractions > 1.0) {
      // Proportional reduction
      for (var key in fractions.keys) {
        double original = fractions[key]!;
        double adjusted = original / sumFractions;
        double amount = netEstate * adjusted;
        String name = _getName(key, input);
        results.add(DetailedHeirShare(
            name: name,
            fraction: original,
            fractionString: _doubleToFraction(original),
            count: _getCount(key, input),
            amount: amount,
            description: reasons[key]! + " (تم إنقاصها بالعول)"));
      }
      return results;
    }

    // Add fixed shares to results
    for (var key in fractions.keys) {
      double amount = netEstate * fractions[key]!;
      results.add(DetailedHeirShare(
          name: _getName(key, input),
          fraction: fractions[key]!,
          fractionString: _doubleToFraction(fractions[key]!),
          count: _getCount(key, input),
          amount: amount,
          description: reasons[key]!));
    }

    // --- IV. Residuary (Asabah) Distribution ---
    double remainingAmount = netEstate * (1.0 - sumFractions);

    if (remainingAmount > 0.001) {
      // Search for Asabah in order of priority
      // 1. Sons & Daughters (bil-ghayr)
      if (input.sons > 0 || input.daughters > 0) {
        int sonsUnits = (input.sons * 2) + input.daughters;
        double unitValue = remainingAmount / sonsUnits;
        double sonsFraction = (input.sons * 2) / sonsUnits;
        double daughtersFraction = input.daughters / sonsUnits;
        if (input.sons > 0)
          results.add(DetailedHeirShare(
              name: "الأبناء",
              fraction: (remainingAmount / netEstate) * sonsFraction,
              fractionString: "عصبة",
              count: input.sons,
              amount: unitValue * 2 * input.sons,
              description: "الباقي تعصيباً (للذكر مثل حظ الأنثيين)",
              isAsabah: true));
        if (input.daughters > 0 && input.sons > 0)
          results.add(DetailedHeirShare(
              name: "البنات",
              fraction: (remainingAmount / netEstate) * daughtersFraction,
              fractionString: "عصبة",
              count: input.daughters,
              amount: unitValue * input.daughters,
              description: "الباقي تعصيباً مع الإخوة",
              isAsabah: true));
      }

      // If no sons, check son's sons
      else if (input.sonsOfSons > 0 || input.daughtersOfSons > 0) {
        int sSonUnits = (input.sonsOfSons * 2) + input.daughtersOfSons;
        double unitValue = remainingAmount / sSonUnits;
        results.add(DetailedHeirShare(
            name: "أبناء الابن",
            fraction: (remainingAmount / netEstate) *
                ((input.sonsOfSons * 2) / sSonUnits),
            fractionString: "عصبة",
            count: input.sonsOfSons,
            amount: unitValue * 2 * input.sonsOfSons,
            description: "الباقي تعصيباً",
            isAsabah: true));
        if (input.daughtersOfSons > 0)
          results.add(DetailedHeirShare(
              name: "بنات الابن",
              fraction: (remainingAmount / netEstate) *
                  (input.daughtersOfSons / sSonUnits),
              fractionString: "عصبة",
              count: input.daughtersOfSons,
              amount: unitValue * input.daughtersOfSons,
              description: "الباقي تعصيباً مع أبناء الابن",
              isAsabah: true));
      }

      // Father as asabah (if only daughters or no branch)
      else if (input.hasFather) {
        results.add(DetailedHeirShare(
            name: "الأب",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: 1,
            amount: remainingAmount,
            description: "الباقي تعصيباً لعدم وجود فرع مذكر",
            isAsabah: true));
      }

      // Grandfather as asabah
      else if (input.hasPaternalGrandfather) {
        // Special Logic: Grandfather vs Siblings
        bool isHanafi = (input.madhab == "الأحناف");
        bool hasSiblings = (input.fullBrothers +
                input.fullSisters +
                input.consanguineBrothers +
                input.consanguineSisters) >
            0;

        if (isHanafi || !hasSiblings) {
          // Hanafi view: Grandfather blocks all siblings
          results.add(DetailedHeirShare(
              name: "الجد",
              fractionString: "عصبة",
              count: 1,
              amount: remainingAmount,
              description: isHanafi && hasSiblings
                  ? "الباقي تعصيباً (يحجب الإخوة عند الأحناف)"
                  : "الباقي تعصيباً لعدم وجود الأب أو فرع مذكر",
              isAsabah: true));
        } else {
          // Jumhur view: Grandfather shares with siblings (Muqasama)
          // Simplified implementation: He shares as a brother
          int brothersCount = input.fullBrothers + input.consanguineBrothers;
          int sistersCount = input.fullSisters + input.consanguineSisters;
          // Grandfather acts as a full brother if only full siblings exist,
          // or consanguine if consanguine exist.
          int totalUnits = ((brothersCount + 1) * 2) + sistersCount;
          double unitValue = remainingAmount / totalUnits;

          results.add(DetailedHeirShare(
              name: "الجد",
              fraction: unitValue * 2 / netEstate,
              fractionString: "مقاسمة",
              count: 1,
              amount: unitValue * 2,
              description: "الباقي تعصيباً بالمقاسمة مع الإخوة (رأي الجمهور)",
              isAsabah: true));

          if (brothersCount > 0) {
            results.add(DetailedHeirShare(
                name: "الإخوة",
                fraction: (unitValue * 2 * brothersCount) / netEstate,
                fractionString: "عصبة",
                count: brothersCount,
                amount: unitValue * 2 * brothersCount,
                description: "الباقي تعصيباً مع الجد",
                isAsabah: true));
          }
          if (sistersCount > 0) {
            results.add(DetailedHeirShare(
                name: "الأخوات",
                fraction: (unitValue * sistersCount) / netEstate,
                fractionString: "عصبة",
                count: sistersCount,
                amount: unitValue * sistersCount,
                description: "الباقي تعصيباً مع الجد والإخوة",
                isAsabah: true));
          }
          // Set remainingAmount to 0 as it's fully distributed
          remainingAmount = 0;
        }
      }

      // Brothers & Sisters
      else if (input.fullBrothers > 0 || input.fullSisters > 0) {
        int fSibUnits = (input.fullBrothers * 2) + input.fullSisters;
        double unitValue = remainingAmount / fSibUnits;
        if (input.fullBrothers > 0)
          results.add(DetailedHeirShare(
              name: "الإخوة الأشقاء",
              fraction: (remainingAmount / netEstate) *
                  ((input.fullBrothers * 2) / fSibUnits),
              fractionString: "عصبة",
              count: input.fullBrothers,
              amount: unitValue * 2 * input.fullBrothers,
              description: "الباقي تعصيباً",
              isAsabah: true));
        if (input.fullSisters > 0)
          results.add(DetailedHeirShare(
              name: "الأخوات الشقيقات",
              fraction: (remainingAmount / netEstate) *
                  (input.fullSisters / fSibUnits),
              fractionString: "عصبة",
              count: input.fullSisters,
              amount: unitValue * input.fullSisters,
              description: "الباقي تعصيباً مع الإخوة",
              isAsabah: true));
      }

      // Consanguine Brothers & Sisters
      else if (input.consanguineBrothers > 0 || input.consanguineSisters > 0) {
        int cSibUnits =
            (input.consanguineBrothers * 2) + input.consanguineSisters;
        double unitValue = remainingAmount / cSibUnits;
        if (input.consanguineBrothers > 0)
          results.add(DetailedHeirShare(
              name: "الإخوة لأب",
              fraction: (remainingAmount / netEstate) *
                  ((input.consanguineBrothers * 2) / cSibUnits),
              fractionString: "عصبة",
              count: input.consanguineBrothers,
              amount: unitValue * 2 * input.consanguineBrothers,
              description: "الباقي تعصيباً",
              isAsabah: true));
        if (input.consanguineSisters > 0)
          results.add(DetailedHeirShare(
              name: "الأخوات لأب",
              fraction: (remainingAmount / netEstate) *
                  (input.consanguineSisters / cSibUnits),
              fractionString: "عصبة",
              count: input.consanguineSisters,
              amount: unitValue * input.consanguineSisters,
              description: "الباقي تعصيباً مع الإخوة لأب",
              isAsabah: true));
      }

      // Nephews, Uncles, etc. (Simplified hierarchy)
      else if (input.nephewsFull > 0)
        results.add(DetailedHeirShare(
            name: "أبناء الأخ الشقيق",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.nephewsFull,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.nephewsConsanguine > 0)
        results.add(DetailedHeirShare(
            name: "أبناء الأخ لأب",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.nephewsConsanguine,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.grandNephewsFull > 0)
        results.add(DetailedHeirShare(
            name: "أبناء ابن الأخ الشقيق",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.grandNephewsFull,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.grandNephewsConsanguine > 0)
        results.add(DetailedHeirShare(
            name: "أبناء ابن الأخ لأب",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.grandNephewsConsanguine,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.paternalUnclesFull > 0)
        results.add(DetailedHeirShare(
            name: "الأعمام الأشقاء",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.paternalUnclesFull,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.paternalUnclesConsanguine > 0)
        results.add(DetailedHeirShare(
            name: "الأعمام لأب",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.paternalUnclesConsanguine,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.cousinsFull > 0)
        results.add(DetailedHeirShare(
            name: "أبناء العم الشقيق",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.cousinsFull,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.cousinsConsanguine > 0)
        results.add(DetailedHeirShare(
            name: "أبناء العم لأب",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.cousinsConsanguine,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.grandCousinsFull > 0)
        results.add(DetailedHeirShare(
            name: "أبناء ابن العم الشقيق",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.grandCousinsFull,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.grandCousinsConsanguine > 0)
        results.add(DetailedHeirShare(
            name: "أبناء ابن العم لأب",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.grandCousinsConsanguine,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.paternalGreatUnclesFull > 0)
        results.add(DetailedHeirShare(
            name: "أعمام الأب الأشقاء",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.paternalGreatUnclesFull,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.paternalGreatUnclesConsanguine > 0)
        results.add(DetailedHeirShare(
            name: "أعمام الأب لأب",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.paternalGreatUnclesConsanguine,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.paternalGreatCousinsFull > 0)
        results.add(DetailedHeirShare(
            name: "أبناء عم الأب الأشقاء",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.paternalGreatCousinsFull,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));
      else if (input.paternalGreatCousinsConsanguine > 0)
        results.add(DetailedHeirShare(
            name: "أبناء عم الأب لأب",
            fraction: remainingAmount / netEstate,
            fractionString: "عصبة",
            count: input.paternalGreatCousinsConsanguine,
            amount: remainingAmount,
            description: "الباقي تعصيباً",
            isAsabah: true));

      // Radd (Return) - if no asabah exist, redistribute to fixed share heirs (except spouse in most madhabs)
      else {
        double raddSum = 0;
        List<DetailedHeirShare> raddables = [];
        bool spouseGetsRadd = (input.madhab == "قانون المواريث المصري");

        for (var res in results) {
          bool isSpouse = (res.name == "الزوج" ||
              res.name == "الزوجة" ||
              res.name == "الزوجات");
          if (!isSpouse ||
              (isSpouse && spouseGetsRadd && results.length == 1)) {
            raddSum += res.fraction;
            raddables.add(res);
          }
        }

        if (raddSum > 0) {
          for (var res in raddables) {
            double heirRaddFraction =
                (remainingAmount / netEstate) * (res.fraction / raddSum);
            int idx = results.indexOf(res);
            results[idx] = DetailedHeirShare(
              name: res.name,
              fraction: res.fraction + heirRaddFraction,
              fractionString:
                  _doubleToFraction(res.fraction + heirRaddFraction),
              amount: res.amount + (remainingAmount * (res.fraction / raddSum)),
              description:
                  res.description + " (بالإضافة إلى الرد لعدم وجود عاصب)",
              count: res.count,
            );
          }
        } else {
          results.add(DetailedHeirShare(
              name: "بيت مال المسلمين",
              fraction: remainingAmount / netEstate,
              fractionString: "الباقي",
              amount: remainingAmount,
              description:
                  "الباقي لعدم وجود ورثة عصبة أو أصحاب فروض يستحقون الرد"));
        }
      }
    }

    // --- V. Final Result Processing (Tashih/Problem Correction) ---
    results = _applyTashih(results, input, netEstate);

    return results;
  }

  static List<DetailedHeirShare> _applyTashih(
      List<DetailedHeirShare> results, HeirsInput input, double heirNetEstate) {
    if (results.isEmpty) return results;

    // 1. Calculate common base (Asl) from fixed fractions
    int base = 1;
    for (var res in results) {
      if (res.fraction > 0) {
        int q = _getDenominator(res.fraction);
        base = _lcm(base, q);
      }
    }

    // 2. Handle Inkisat (Incommensurability)
    int finalMultiplier = 1;
    for (var res in results) {
      if (res.count > 1) {
        int groupUnits = res.count;
        // The fraction already accounts for 2:1 splits, so we just need to
        // ensure the group's total arrows are divisible by the number of individuals.

        // Find arrows for the group in the current base
        double arrows = res.fraction * base;
        int intArrows = arrows.round();

        // Relationship between arrows and units (Tawafuq/Tabayun)
        int common = _gcd(intArrows, groupUnits);
        int multiplierNeeded = groupUnits ~/ common;
        finalMultiplier = _lcm(finalMultiplier, multiplierNeeded);
      }
    }

    base = base * finalMultiplier;

    // 3. Map back to final integer numerators
    List<DetailedHeirShare> finalResults = [];
    for (var res in results) {
      int numerator = (res.fraction * base).round();

      finalResults.add(DetailedHeirShare(
        name: res.name,
        fraction: res.fraction,
        fractionString: res.fractionString,
        amount: res.amount,
        description: res.description,
        isAsabah: res.isAsabah,
        count: res.count,
        numerator: numerator,
        denominator: base,
      ));
    }

    return finalResults;
  }

  static int _getDenominator(double fraction) {
    if ((fraction - 0.5).abs() < 0.001) return 2;
    if ((fraction - 0.25).abs() < 0.001) return 4;
    if ((fraction - 0.125).abs() < 0.001) return 8;
    if ((fraction - (1 / 3)).abs() < 0.001) return 3;
    if ((fraction - (2 / 3)).abs() < 0.001) return 3;
    if ((fraction - (1 / 6)).abs() < 0.001) return 6;
    if ((fraction - (1 / 12)).abs() < 0.001) return 12;
    if ((fraction - (1 / 24)).abs() < 0.001) return 24;
    // Awl/Radd cases can have complex denominators
    // We can use a search or generic ratio
    for (int d = 2; d <= 480; d++) {
      double val = fraction * d;
      if ((val - val.round()).abs() < 0.001) return d;
    }
    return 100;
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  static int _lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a * b) ~/ _gcd(a, b);
  }

  static String _doubleToFraction(double value) {
    if (value <= 0) return "0";
    if ((value - 0.5).abs() < 0.01) return "1/2";
    if ((value - 0.25).abs() < 0.01) return "1/4";
    if ((value - 0.125).abs() < 0.01) return "1/8";
    if ((value - 0.333).abs() < 0.01) return "1/3";
    if ((value - 0.666).abs() < 0.01) return "2/3";
    if ((value - 0.166).abs() < 0.01) return "1/6";
    if ((value - (1 / 3)).abs() < 0.001) return "1/3";
    if ((value - (2 / 3)).abs() < 0.001) return "2/3";
    if ((value - (1 / 6)).abs() < 0.001) return "1/6";

    // Fallback to percentage or generic
    return "${(value * 100).toStringAsFixed(1)}%";
  }

  static double _fractionToDouble(String fraction) {
    if (fraction == "لا يوجد") return 0;
    try {
      List<String> parts = fraction.split('/');
      if (parts.length == 2) {
        return double.parse(parts[0]) / double.parse(parts[1]);
      }
    } catch (e) {}
    return 0;
  }

  static int _getCount(String key, HeirsInput input) {
    switch (key) {
      case "husband":
        return 1;
      case "wives":
        return input.wives;
      case "mother":
        return 1;
      case "father":
        return 1;
      case "grandfather":
        return 1;
      case "grandmother":
        return (input.hasMaternalGrandmother ? 1 : 0) +
            (input.hasPaternalGrandmother ? 1 : 0);
      case "daughters":
        return input.daughters;
      case "grand_daughters":
        return input.daughtersOfSons;
      case "uterine":
        return input.uterineBrothers + input.uterineSisters;
      case "uterine_plus_full":
        return input.uterineBrothers +
            input.uterineSisters +
            input.fullBrothers;
      case "full_sisters":
        return input.fullSisters;
      default:
        return 1;
    }
  }

  static String _getName(String key, HeirsInput input) {
    switch (key) {
      case "husband":
        return "الزوج";
      case "wives":
        return input.wives > 1 ? "الزوجات (${input.wives})" : "الزوجة";
      case "mother":
        return "الأم";
      case "father":
        return "الأب";
      case "grandfather":
        return "الجد";
      case "grandmother":
        return "الجدة";
      case "daughters":
        return input.daughters > 1 ? "البنات (${input.daughters})" : "البنت";
      case "grand_daughters":
        return "بنات الابن";
      case "uterine":
        return "الإخوة لأم";
      case "uterine_plus_full":
        return "الإخوة لأم والأشقاء (مشتركة)";
      case "full_sisters":
        return "الأخوات الشقيقات";
      case "grandNephewsFull":
        return "أبناء ابن الأخ الشقيق";
      case "grandNephewsConsanguine":
        return "أبناء ابن الأخ لأب";
      case "grandCousinsFull":
        return "أبناء ابن العم الشقيق";
      case "grandCousinsConsanguine":
        return "أبناء ابن العم لأب";
      case "paternalGreatUnclesFull":
        return "أعمام الأب الأشقاء";
      case "paternalGreatUnclesConsanguine":
        return "أعمام الأب لأب";
      case "paternalGreatCousinsFull":
        return "أبناء عم الأب الأشقاء";
      case "paternalGreatCousinsConsanguine":
        return "أبناء عم الأب لأب";
      default:
        return key;
    }
  }
}
