import 'package:dartz/dartz.dart';

import '../modal/quran_audio_modal.dart';
import '../modal/quran_details_modal.dart';

abstract class QuranDetailsRepo {
  Future<Either<dynamic, QuranAudioModal>> getQuranAudio();
  Future<Either<dynamic, QuranDetailsModal>> getQuranDetails(
      {dynamic recitersId});

}
