
import '../localization/localization_manager.dart';

///////////  Start Validator class /////////////
class Validator {
  //////  Start Validator Email ///////
  static String? email(String? value) {
    if (value!.isEmpty) {
      return LocalizationManager.call('email_validator1');
    } else if (!value.contains('@') || !value.contains('.com')) {
      return 'EX: rafiq@rafiq.com';
    } else {
      return null;
    }
  }
  //////  End Validator Email ///////

  //////  Start Validator Password ///////

  static String? password(String? value) {
    if (value!.isEmpty) {
      return LocalizationManager.call('password_validator2');
    } else if (value.length < 6) {
      return LocalizationManager.call('password_validator2');
    } else {
      return null;
    }
  }
  //////  End Validator Password ///////

  //////  Start Validator Title ///////
  static String? name(String? value) {
    if (value!.isEmpty) {
      return LocalizationManager.call('name_validator2');
    } else if (value.length < 8) {
      return LocalizationManager.call('name_validator2');
    } else {
      return null;
    }
    //////  End Validator Title ///////
  }

  //////  Start Validator Time ///////
  static String? time(String? value) {
    if (value!.isEmpty) {
      return 'Time Empty!';
    } else if (value.length <= 2) {
      return 'Time invalid';
    } else {
      return null;
    }
  }

  //////  End Validator Time ///////
  //////  Start Validator phone ///////
  static String? mobilePhone(String? value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    // ignore: prefer_is_empty
    if (value!.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  //////  End Validator phone ///////
  //////  Start Validator Date ///////
  static String? date(String? value) {
    if (value!.isEmpty) {
      return 'Date Empty!';
    } else if (value.length <= 2) {
      return 'Date invalid';
    } else {
      return null;
    }
  }
//////  End Validator Date ///////

// static String? confirmPassword(String? value) {
//   if (value!.isEmpty) {
//     return 'Invalid Confirm!';
//   } else if (LoginController().password !=LoginController().confirm) {
//     return 'please enter match password';
//   } else {
//     return null;
//   }
// }

  static String? comment(String? value) {
    if (value!.isEmpty) {
      return LocalizationManager.call('comment-valid1');
    } else if (value.length < 2) {
      return LocalizationManager.call('comment-valid2');
    } else {
      return null;
    }
    //////  End Validator Title ///////
  }
}

///////////  End Validator class /////////////
