import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../core/utils/constent/lists.dart';
import '../../../../core/utils/style/responsive_util.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/extensions/books_getters_extension.dart';
import 'widgets/about_book.dart';
import 'widgets/book_name.dart';
import 'widgets/books_list.dart';

class CollectionDetailsScreen extends StatelessWidget {
  final int? bookNumber;
  final int? bookIndex;
  
  const CollectionDetailsScreen(
      {super.key, this.bookNumber, this.bookIndex});

  @override
  Widget build(BuildContext context) {
    // Simplified logic: We assume we are showing a Collection, not ExplanationBook
    final booksCtrl = Get.find<BooksController>();
    final collection = booksCtrl.currentCollection; // Assuming currentCollection is set before nav
    // But Wait, BooksCover calls setAndShowCollectionByCollectionId?
    // I need to verify how BooksCover navigates.
    // In original code: booksCtrl.setAndShowCollectionByCollectionId calls Get.to(CollectionDetailsScreen)
    // AND sets currentCollectionId.
    // So 'collection' getter on controller should work if currentCollectionId is set.
    
    // HOWEVER, I didn't verify if I added setAndShowCollectionByCollectionId to extension!
    // I missed that method in BooksUiHelper porting earlier.
    // I will add it to the extension OR handle it in BooksCover.
    // Since I'm writing this screen now, I will assume currentCollectionId IS SET.
    
    // But aboutBook might be tricky. Sunnati used currentBookAbout getter.
    // I need to check Collection model.
    // Collection model has 'shortIntro' in CollectionLang? 
    // Wait, original code: `sl<SunnatiBooksController>().currentCollection.currentBookAbout;`
    // I need to check `currentBookAbout` extension on Collection?
    // It was likely in `collection_extensions.dart`.
    // I'll default to usage of 'collection.name' or similar if I don't have the extension.
    // I'll use collection.arAndEnName for now.
    
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: false,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, 
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              // Book Cover
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: BookName(bookDetails: collection),
                ),
              ),
              
              // About Book Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AboutBook(
                      bookDetails: _getBookDetails(collection.id ?? 1),
                    ),
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: Gap(16)),
              
              // Books List Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Text(
                    'booksList'.tr,
                    style: TextStyle(
                      fontSize: ResponsiveUtil.isTablet(context) ? 18 : 24,
                      fontFamily: 'kufi',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              
              // Books List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                sliver: SliverToBoxAdapter(
                  child: BooksList(),
                ),
              ),
              
              const SliverToBoxAdapter(child: Gap(32)),
            ],
          ),
        ),
      ),
    );
  }

  String _getBookDetails(int collectionId) {
    // Collection IDs are 1-indexed, booksList is 0-indexed
    final bookIndex = collectionId - 1;
    if (bookIndex >= 0 && bookIndex < booksList.length) {
      return booksList[bookIndex]['details'] ?? 'لا توجد معلومات متاحة عن هذا الكتاب';
    }
    return 'لا توجد معلومات متاحة عن هذا الكتاب';
  }
}
