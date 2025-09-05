import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/localization/localization_manager.dart';
import '../categories/data/repo/categories_repo_immp.dart';
import '../categories/view/categories_details.dart';
import '../categories/view/controller/categories_bloc.dart';

class CategoriesDetailsView extends StatelessWidget {
  final CategoriesDetailsPrams? categoriesDetailsPrams;

  const CategoriesDetailsView({super.key, this.categoriesDetailsPrams});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoriesBloc>(
        create: (BuildContext context) => CategoriesBloc(CategoriesRepoImmp())
          ..getAllHadithFromCategories(
              categoriesId: categoriesDetailsPrams?.categoriesId),
        child: Directionality(
            textDirection: LocalizationManager.isEn
                ? TextDirection.ltr
                : TextDirection.rtl,
            child: Scaffold(

                body: SafeArea(
                    child: CategoriesDetailsItemBuilder(
                        categoriesDetailsPrams: categoriesDetailsPrams)))));
  }
}
