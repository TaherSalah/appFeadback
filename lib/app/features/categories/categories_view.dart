import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/features/categories/view/controller/categories_bloc.dart';
import 'package:muslimdaily/app/features/categories/view/widget/categories_view_item_builder.dart';

import '../../core/localization/localization_manager.dart';
import '../../core/shard/constanc/app_style.dart';
import '../../core/shard/exports/all_exports.dart';
import 'data/repo/categories_repo_immp.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

    return BlocProvider<CategoriesBloc>(
        create: (BuildContext context) =>
            CategoriesBloc(CategoriesRepoImmp())..getAllCategories(),
        child: Directionality(
            textDirection: LocalizationManager.isEn
                ? TextDirection.ltr
                : TextDirection.rtl,
            child: Scaffold(
                // backgroundColor: AppStyle.bgColors,

                key: scaffoldState,
                body: const CategoriesViewItemBuilder())));
  }
}
