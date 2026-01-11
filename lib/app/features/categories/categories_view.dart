import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/features/categories/view/controller/categories_bloc.dart';
import 'package:muslimdaily/app/features/categories/view/widget/categories_view_item_builder.dart';

import '../../core/localization/localization_manager.dart';

import '../../core/shard/exports/all_exports.dart';
import '../../core/widgets/no_internet_dialog.dart';
import 'data/repo/categories_repo_immp.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  late CategoriesBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = CategoriesBloc(CategoriesRepoImmp());
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoInternetDialog();
      });
    } else {
      _loadData();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => NoInternetDialog(
        onRetrySuccess: () {
          Navigator.pop(ctx); // Close dialog
          _loadData(); // Load data
        },
      ),
    );
  }

  void _loadData() {
    _bloc.getAllCategories();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Directionality(
        textDirection: LocalizationManager.isEn
            ? TextDirection.ltr
            : TextDirection.rtl,
        child: Scaffold(
          key: scaffoldState,
          body: const CategoriesViewItemBuilder(),
        ),
      ),
    );
  }
}
