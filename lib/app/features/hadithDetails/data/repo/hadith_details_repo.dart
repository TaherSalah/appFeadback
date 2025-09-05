import 'package:dartz/dartz.dart';

import '../../../../core/errors/failuers.dart';
import '../../../categories/data/modal/all_hadith_categories_modal.dart';
import '../modal/hadith_details_modal.dart';


abstract class HadithDetailsRepo {
  Future<Either<dynamic, HadithDetailsModal>> getHadithDetails(
      {dynamic hadithId});
  Future<Either<dynamic, List<HadithDetailsModal>>> getHadithDetailsList(
      {dynamic hadithId});
  Future<Either<KFailure, List<AllHadithCategorieModal>>> getMoreHadith(
      {dynamic hadithId});
}
