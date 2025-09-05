// ignore_for_file: constant_identifier_names, non_constant_identifier_names


import '../localization/localization_manager.dart';

class ErrorCodes {
  static const String ERROR_CODE_WRONG_PASSWORD = "wrong-password";
  static const String ERROR_CODE_INVALID_EMAIL = "invalid-email";
  static const String ERROR_CODE_USER_NOT_FOUND = "user-not-found";
  static const String ERROR_CODE_USER_DISABLED = "user-disabled";
  static const String ERROR_CODE_EMAIL_ALREADY_IN_USE = "email-already-in-use";
  static const String ERROR_CODE_OPERATION_NOT_ALLOWED =
      "operation-not-allowed";
  static const String ERROR_CODE_WEAK_PASSWORD = "weak-password";
  static const String ERROR_CODE_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL =
      "account-exists-with-different-credential";
  static const String ERROR_CODE_INVALID_VERIFICATION_CODE =
      "invalid-verification-code";
  static const String ERROR_CODE_INVALID_VERIFICATION_ID =
      "invalid-verification-id";
  static const String ERROR_CODE_USER_MISMATCH = "user-mismatch";
  static const String ERROR_CODE_INVALID_CREDENTIAL = "invalid-credential";
  static const String ERROR_CODE_EXPIRED_ACTION_CODE = "expired-action-code";
  static const String ERROR_C0DE_NETWORK_ERROR = "FirebaseException";
  static const String ERROR_USER_NOT_FOUND = "ERROR_USER_NOT_FOUND";
  static const String ERROR_TOO_MANY_REQUESTS = "ERROR_TOO_MANY_REQUESTS";
  static const String ERROR_INVALID_EMAIL = "ERROR_INVALID_EMAIL";
  static const String ERROR_OPERATION_NOT_ALLOWED =
      "ERROR_OPERATION_NOT_ALLOWED";
  static const String ERROR_CODE_REQUIRES_RECENT_LOGIN =
      "requires-recent-login";
  static const String INVALID_PHONE_NUMBER = "invalid-phone-number";
  static const String QUOTA_EXCEEDED = "quota-exceeded";
  static const String SESSION_EXPIRED = "session-expired";
  static const String TOO_MANY_REQUESTES = "too-many-requests";
  static const String NETWORK_REQUEST_FAILED = "network-request-failed";
  static const String CREDENTIAL_ALREADY_IN_USE = "credential-already-in-use";
  static const String UNAVAILABLE = "unavailable";
  static const String UNKNOWN = "unknown";
}

class ErrorMessages {
  static String ERROR_CODE_WRONG_PASSWORD =
      // LocalizationManager.call("wrong-password");
      "wrong-password";
  static String ERROR_CODE_INVALID_EMAIL =
      // LocalizationManager.call("invalid-email");
      "invalid-email";
  static String ERROR_CODE_USER_NOT_FOUND =
      LocalizationManager.call("user-not-found");
  static String ERROR_CODE_USER_DISABLED =
      LocalizationManager.call("user-disabled");
  static String ERROR_CODE_EMAIL_ALREADY_IN_USE =
      LocalizationManager.call("email-already-in-use");
  static String ERROR_CODE_OPERATION_NOT_ALLOWED =
      LocalizationManager.call("operation-not-allowed");
  static String ERROR_CODE_WEAK_PASSWORD =
      LocalizationManager.call("weak-password");
  static String ERROR_CODE_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL =
      LocalizationManager.call("account-exists-with-different-credential");
  static String ERROR_CODE_INVALID_VERIFICATION_CODE =
      LocalizationManager.call("invalid-verification-code");
  static String ERROR_CODE_INVALID_VERIFICATION_ID =
      LocalizationManager.call("invalid-verification-id");
  static String ERROR_CODE_USER_MISMATCH =
      LocalizationManager.call("user-mismatch");
  static String ERROR_CODE_INVALID_CREDENTIAL =
      LocalizationManager.call("invalid-credential");
  static String ERROR_CODE_EXPIRED_ACTION_CODE =
      LocalizationManager.call("expired-action-code");
  static String ERROR_C0DE_NETWORK_ERROR =
      LocalizationManager.call("FirebaseException");
  static String ERROR_USER_NOT_FOUND =
      LocalizationManager.call("ERROR_USER_NOT_FOUND");
  static String ERROR_TOO_MANY_REQUESTS =
      LocalizationManager.call("ERROR_TOO_MANY_REQUESTS");
  static String ERROR_INVALID_EMAIL =
      LocalizationManager.call("ERROR_INVALID_EMAIL");
  static String ERROR_OPERATION_NOT_ALLOWED =
      LocalizationManager.call("ERROR_OPERATION_NOT_ALLOWED");
  static String ERROR_CODE_REQUIRES_RECENT_LOGIN =
      LocalizationManager.call("requires-recent-login");
  static String ERROR_INVALID_PHONE_NUMBER =
      LocalizationManager.call("invalid-phone-number");
  static String ERROR_QUOTA_EXCEEDED =
      LocalizationManager.call("quota-exceeded");
  static String ERROR_SESSION_EXPIRED =
      LocalizationManager.call("session-expired");
  static String ERROR_TOO_MANY_REQUESTES =
      LocalizationManager.call("too-many-requests");
  static String ERROR_NETWORK_REQUEST_FAILED =
      LocalizationManager.call("network-request-failed");
  static String ERROR_CREDENTIAL_ALREADY_IN_USE =
      LocalizationManager.call("credential-already-in-use");
  static String ERROR_UNAVAILABLE = LocalizationManager.call("unavailable");
  static String ERROR_UNKNOWN = LocalizationManager.call("unknown");
  static String DEFAULT = LocalizationManager.call("DEFAULT");
}
