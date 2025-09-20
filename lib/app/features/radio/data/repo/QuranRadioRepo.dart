import 'package:dartz/dartz.dart';
import 'package:muslimdaily/app/features/radio/data/modal/QuranRadioModel.dart';



abstract class QuranRadioRepo {
  Future<Either<dynamic, QuranRadioModel>> getQuranRadioData();

}
