import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

class KStorageKeys {
  static const String themeMode = 'themeMode';
  static const String isEng = 'isEng';
  static const String token = 'token';
  static const String userModel = 'userModel';
  static const String setting = 'setting';
  static const String isOnboardingSeen = 'isOnboardingSeen';
  static const String settings = 'settings';
  static const String email = 'email';
  static const String forgetEmail = 'forgetEmail';
  static const String examName = 'examName';
  static const String examId = 'examId';
  static const String examAttempId = 'examAttemp';
  static const String examType = 'examType';
  static const String saveTime = 'saveTime';
  static const String examAttempRes = 'examAttempRes';
  static const String isTraining = 'isTraining';
  static const String isConfirm = 'isConfirm';
  static const String isNext = 'isNext';
  static const String isSkip = 'isSkip';
  static const String userImg = 'userImg';
  static const String saveDiscount = 'saveDiscount';
  static const String isExamActive = 'isExamActive';
  static const String isExamAdded = 'isExamAdded';
  static const String isPackagesExamAdded = 'isPackagesExamAdded';
  static const String isLogGoogle = 'isLogGoogle';
  static const String examIdes = 'examIdes';
  static const String cartDataModel = 'cartDataModel';
  static const String levelAttemp = 'levelAttemp';
  static const String examLevelsList = 'examLevelsList';
  static const String examLevelsListLength = 'examLevelsListLength';
  static const String attmpetIdExDetails = 'attmpetIdExDetails';

  static const String isAttmpetExDetView = 'isAttmpetExDetView';
}

class KStorage {
  KStorage();

  final GetStorage _storage = GetStorage();
  static KStorage i = _kStorage;

  static KStorage get _kStorage {
    if (GetIt.instance.isRegistered<KStorage>()) {
      return GetIt.instance.get<KStorage>();
    } else {
      GetIt.instance.registerLazySingleton(() => KStorage());
      return GetIt.instance.get<KStorage>();
    }
  }

  get erase async => await _storage.erase();

  setToken(dynamic token) => _storage.write(KStorageKeys.token, token);

  setIsEng(bool? isEng) => _storage.write(KStorageKeys.isEng, isEng);

  setLevelAttemp(dynamic levelAttemp) =>
      _storage.write(KStorageKeys.levelAttemp, levelAttemp);

  setExamLevelsList(List? examLevelsList) =>
      _storage.write(KStorageKeys.examLevelsList, examLevelsList);

  setExamLevelsLength(int? examLevelsLength) =>
      _storage.write(KStorageKeys.examLevelsListLength, examLevelsLength);

  setIsLogGoogle(bool? isLogGoogle) =>
      _storage.write(KStorageKeys.isLogGoogle, isLogGoogle);

  setExamIds({List? examIdes}) =>
      _storage.write(KStorageKeys.examIdes, examIdes);

  setIsAttmpetExDetView({bool? isAttemptView}) =>
      _storage.write(KStorageKeys.isAttmpetExDetView, isAttemptView);

  setIsPackagesExamAdded(bool? isPackagesExamAdded) =>
      _storage.write(KStorageKeys.isPackagesExamAdded, isPackagesExamAdded);

  setExamName(String? examName) =>
      _storage.write(KStorageKeys.examName, examName);

  setExamId(int? examId) => _storage.write(KStorageKeys.examId, examId);

  setExamAttemp(dynamic examAttemp) =>
      _storage.write(KStorageKeys.examAttempId, examAttemp);

  setExamAttempRes(dynamic examAttemp) =>
      _storage.write(KStorageKeys.examAttempRes, examAttemp);

  setExamType(String? examType) =>
      _storage.write(KStorageKeys.examType, examType);

  setIsOnboardingSeen(bool? isSeen) =>
      _storage.write(KStorageKeys.isOnboardingSeen, isSeen);

  setIsExamActive(bool? isExamActive) =>
      _storage.write(KStorageKeys.isExamActive, isExamActive);

  setIsExamAdded(bool? isExamAdded) =>
      _storage.write(KStorageKeys.isExamAdded, isExamAdded);

  setIsTraining(bool? isTraining) =>
      _storage.write(KStorageKeys.isTraining, isTraining);

  setIsConfirm(int? isConfirm) =>
      _storage.write(KStorageKeys.isConfirm, isConfirm);

  setIsNext(int? isNext) => _storage.write(KStorageKeys.isNext, isNext);

  setIsSkip(int? isSkip) => _storage.write(KStorageKeys.isNext, isSkip);

  setEmail(String? email) => _storage.write(KStorageKeys.email, email);

  setTime(String? time) => _storage.write(KStorageKeys.saveTime, time);

  setUserImg(String? userImg) => _storage.write(KStorageKeys.userImg, userImg);

  setAttmpetIdExDetails(int? setAttmpetIdExDetails) =>
      _storage.write(KStorageKeys.attmpetIdExDetails, setAttmpetIdExDetails);

  setSaveDiscount(String? saveDiscount) =>
      _storage.write(KStorageKeys.saveDiscount, saveDiscount);

  setForgetEmail(String? email) =>
      _storage.write(KStorageKeys.forgetEmail, email);

  String? get getTimeSave => _storage.read(KStorageKeys.saveTime);

  dynamic get getLevelAttemp => _storage.read(KStorageKeys.levelAttemp);

  List? get getExamLevelsList => _storage.read(KStorageKeys.examLevelsList);

  int? get getExamLevelsLength =>
      _storage.read(KStorageKeys.examLevelsListLength);

  List? get getExamIds => _storage.read(KStorageKeys.examIdes);

  bool? get getIsAttemptExDetView =>
      _storage.read(KStorageKeys.isAttmpetExDetView);

  bool? get getIsExamActive => _storage.read(KStorageKeys.isExamActive);

  bool? get getIsEg => _storage.read(KStorageKeys.isEng);

  bool? get getIsLogGoogle => _storage.read(KStorageKeys.isLogGoogle);

  bool? get getIsExamAdded => _storage.read(KStorageKeys.isExamAdded);

  bool? get getIsPackagesExamAdded =>
      _storage.read(KStorageKeys.isPackagesExamAdded);

  String? get getSaveDiscount => _storage.read(KStorageKeys.saveDiscount);

  String? get getExamName => _storage.read(KStorageKeys.examName);

  String? get getUserImg => _storage.read(KStorageKeys.userImg);

  int? get getExamId => _storage.read(KStorageKeys.examId);

  bool? get getIsTraining => _storage.read(KStorageKeys.isTraining);

  int? get getIsConfirm => _storage.read(KStorageKeys.isConfirm);

  int? get getIsNext => _storage.read(KStorageKeys.isNext);

  int? get getIsSkip => _storage.read(KStorageKeys.isSkip);

  dynamic get getExamAttemp => _storage.read(KStorageKeys.examAttempId);

  dynamic get getExamAttempRes => _storage.read(KStorageKeys.examAttempRes);

  int? get getAttmpetIdExDetails =>
      _storage.read(KStorageKeys.attmpetIdExDetails);

  String? get getExamType => _storage.read(KStorageKeys.examType);

  String? get getEmail => _storage.read(KStorageKeys.email);

  String? get getForgetEmail => _storage.read(KStorageKeys.forgetEmail);

  dynamic get getToken => _storage.read(KStorageKeys.token);

  bool? get getIsOnboardingSeen => _storage.read(KStorageKeys.isOnboardingSeen);

//// Remove
  get delToken => _storage.remove(KStorageKeys.token);

  get delIsPackagesExamAdded =>
      _storage.remove(KStorageKeys.isPackagesExamAdded);

  get delUserImg => _storage.remove(KStorageKeys.userImg);

  get delIsActiveExam => _storage.remove(KStorageKeys.isExamActive);

  get delIsAddExam => _storage.remove(KStorageKeys.isExamAdded);

  get delForEmail => _storage.remove(KStorageKeys.forgetEmail);

  get delDiscount => _storage.remove(KStorageKeys.saveDiscount);

  get delIsLogGoogle => _storage.remove(KStorageKeys.isLogGoogle);

  get delExamAttempRes => _storage.remove(KStorageKeys.examAttempRes);

  get delTime => _storage.remove(KStorageKeys.saveTime);

  get delExamIds => _storage.remove(KStorageKeys.examIdes);

  List<String> myFavoriteList = [];

  saveFav(String id) {
    myFavoriteList.add(id);
    _storage.write('favoriteArticles', myFavoriteList.cast<String>());
  }

  ifExistInFav(String id) async {
    bool ifExists = false;
    List<String> my = (_storage.read('favoriteArticles').cast<String>() ?? []);
    ifExists = my.contains(id) ? true : false;
    return ifExists;
  }

  // setCartData(dynamic cartData) =>
  //     _storage.write(KStorageKeys.cartDataModel, cartData);
  // setCartData(CartDataModel? cartModel) =>
  //     _storage.write(KStorageKeys.cartDataModel, cartModel?.toJson());
  //
  // CartDataModel? get getCartList {
  //   if (_storage.read(KStorageKeys.cartDataModel) != null) {
  //     return CartDataModel.fromJson(_storage.read(KStorageKeys.cartDataModel));
  //   } else {
  //     return null;
  //   }
  // }
  //
  // setUserInfo(UserProfileModal? model) => _storage.write(
  //     KStorageKeys.userModel, model?.toJson() as Map<String, dynamic>);
  // //
  // get delUserInfo => _storage.remove(KStorageKeys.userModel);
  // //
  // UserProfileModal? get getUserInfo {
  //   if (_storage.read(KStorageKeys.userModel) != null) {
  //     return UserProfileModal.fromJson(_storage.read(KStorageKeys.userModel));
  //   } else {
  //     return null;
  //   }
  // }
}
