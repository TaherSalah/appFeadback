import 'package:dartz/dartz.dart';

import '../../../radioView/data/modal/QuranRadioModel.dart';



abstract class QuranRadioRepo {
  Future<Either<dynamic, QuranRadioModel>> getQuranRadioData();

}
