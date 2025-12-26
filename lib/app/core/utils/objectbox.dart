import 'dart:developer' show log;
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../objectbox.g.dart'; // Ensure correct path to generated file
import '../../features/hadith_books/data/models/ar_hadith_model.dart';
import '../../features/hadith_books/data/models/collection_model.dart';
import '../../features/hadith_books/data/models/en_hadith_model.dart';
import '../../features/hadith_books/data/models/ur_hadith_model.dart';

class ObjBox {
  late final Store store;

  late final Box<Collection> collectionsBox;

  late final Box<ARHadithModel> arHadithsBox;
  late final Box<ENHadithModel> enHadithsBox;
  late final Box<URHadithModel> urHadithsBox;

  ObjBox._create(this.store) {
    collectionsBox = Box<Collection>(store);
    arHadithsBox = Box<ARHadithModel>(store);
    enHadithsBox = Box<ENHadithModel>(store);
    urHadithsBox = Box<URHadithModel>(store);
  }

  static Future<ObjBox> create() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String finalPath = join(dir.path, 'rafiq_hadith_data');
    final directory = Directory(finalPath);

    try {
      if (!await directory.exists()) {
        log("Directory does not exist, creating it: $finalPath");
        await directory.create(recursive: true);
      }
      final Store openedStore = await openStore(directory: finalPath);
      return ObjBox._create(openedStore);
    } catch (e) {
      log("Error opening ObjectBox store: $e");
      
      // Handle UID mismatch or schema conflict by clearing the store and retrying once
      final errorMsg = e.toString();
      if (errorMsg.contains('UID') || errorMsg.contains('match') || errorMsg.contains('Existing entity')) {
        log("ObjectBox UID mismatch or schema conflict detected. Clearing store and retrying...");
        try {
          if (await directory.exists()) {
            await directory.delete(recursive: true);
          }
          await directory.create(recursive: true);
          final Store retriedStore = await openStore(directory: finalPath);
          log("ObjectBox store recreated successfully after conflict.");
          return ObjBox._create(retriedStore);
        } catch (retryError) {
          log("Critical error during ObjectBox retry: $retryError");
          rethrow;
        }
      }
      rethrow;
    }
  }
}
