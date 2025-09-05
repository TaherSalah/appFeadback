class ValidationText {
  static bool isValidName(String name) {
    final nameRegExpEn =
        RegExp(r"^\s*([A-Za-zء-ي]{1,}([\.,] |[-']| ))+[A-Za-zء-ي]+\.?\s*$");
    return nameRegExpEn.hasMatch(name);
  }

  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    final passwordRegExp = RegExp(r"(?=.*[0-9a-zA-Z]).{6,}");
    return passwordRegExp.hasMatch(password);
  }

  static bool isValidKsaPhone(String phone) {
    final phoneRegExp = RegExp(r"^(\+9665|05)(5|0|3|6|4|9|1|8|7)([0-9]{7})$");
    return phoneRegExp.hasMatch(phone);
  }

  static bool isIBANumber(String number) {
    final input = getCleanedNumber(number);
    RegExp cardno = RegExp(r"^\d{22}$");

    return cardno.hasMatch(input);
  }

  static bool isCardumber(String number) {
    final input = getCleanedNumber(number);
    RegExp cardno = RegExp(r"^\d{16}$");

    return cardno.hasMatch(input);
  }

  static String getCleanedNumber(String text) {
    RegExp regExp = RegExp(r"[^0-9]");
    return text.replaceAll(regExp, '');
  }
}
