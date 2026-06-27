import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslimdaily/app/features/radioView/data/repo/QuranRadioRepoImmp.dart';
import 'package:muslimdaily/app/features/radioView/view/controller/QuranRadioBloc.dart';
import 'package:muslimdaily/app/features/radioView/view/controller/QuranRadioState.dart';

import '../../../../core/shard/exports/all_exports.dart';
import '../../../../core/utils/constent/router.dart';
import '../../../../core/utils/style/app_theme_colors.dart';
import '../../../../core/utils/style/k_color.dart';
import '../../../../core/utils/style/k_helper.dart';
import '../../../../core/widgets/KLoading.dart';
import '../../../../core/widgets/custom_text_widget.dart';

class QuranRadioItemBuilder extends StatefulWidget {
  const QuranRadioItemBuilder({super.key});

  @override
  State<QuranRadioItemBuilder> createState() => _QuranRadioItemBuilderState();
}

class _QuranRadioItemBuilderState extends State<QuranRadioItemBuilder> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  static const int _pageSize = 30;
  int _visibleCount = _pageSize;
  bool _isLoadingMore = false;

  List<String> _favUrls = [];
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favUrls = prefs.getStringList('favorite_radios') ?? [];
    });
  }

  Future<void> _toggleFavorite(String url) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favUrls.contains(url)) {
        _favUrls.remove(url);
        KHelper.showSuccess(message: "تم الإزالة من المفضلة");
      } else {
        _favUrls.add(url);
        KHelper.showSuccess(message: "تمت الإضافة للمفضلة ");
      }
    });
    await prefs.setStringList('favorite_radios', _favUrls);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    // قربنا من آخر السكروول؟ زوّد الدُفعة الجاية
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    // مفيش API call هنا — مجرد زيادة العرض من اللي متخزن بالفعل
    Future.microtask(() {
      setState(() {
        _visibleCount += _pageSize;
        _isLoadingMore = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth < 600) {
      // Mobile
      crossAxisCount = 2;
      childAspectRatio = 2.1; // 🚀 Decreased from 2.50 to 2.1 for more height
    } else if (screenWidth < 1200) {
      // Tablet
      crossAxisCount = 3;
      childAspectRatio = 1.5; // 🚀 Decreased from 1.70 to 1.5 for more height
    } else {
      // Desktop
      crossAxisCount = 4;
      childAspectRatio = 0.8; // 🚀 Adjusted for desktop
    }

    return BlocProvider<QuranRadioBloc>(
      create: (context) =>
          QuranRadioBloc(QuranRadioRepoImmp())..getQuranRadioData(),
      child: BlocBuilder<QuranRadioBloc, QuranRadioState>(
        builder: (context, state) {
          final bloc = QuranRadioBloc.get(context);
          final allRadios = bloc.quranRadioModel?.radios ?? [];
          
          var filteredRadios = _showFavoritesOnly 
              ? allRadios.where((r) => _favUrls.contains(r.url.toString())).toList()
              : allRadios;

          if (_searchQuery.isNotEmpty) {
             filteredRadios = filteredRadios.where((r) => (r.name.toString()).contains(_searchQuery)).toList();
          }

          final total = filteredRadios.length;

          // حدّ أقصى لما نعرضه حسب الإجمالي
          final itemCount =
              total == 0 ? 0 : (_visibleCount > total ? total : _visibleCount);
          final isDark = context.isDark;

          // لو لسه محمّل البيانات الأساسية
          final isInitialLoading =
              total == 0 && (state is QuranRadioStateLoading);

          return CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              SliverAppBar(
                centerTitle: true,
                title: Text(
                  "اذاعة القران الكريم",
                  style: TextStyle(
                  fontFamily: "cairo",
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        context.isTab ? 12.sp : 18.sp,
                  ),
                ),
                leading: const SizedBox(),
                actions: [
                  Navigator.canPop(context)
                      ? InkWell(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(
                            "assets/icons/arrow.svg",
                            color: isDark ? Colors.white : Colors.black,
                            height: 25,
                          ),
                        )
                      : const SizedBox()
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _visibleCount = _pageSize; // Reset pagination on search
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "ابحث عن إذاعة...",
                      prefixIcon: const Icon(Icons.search, color: Colors.green),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('الكل', style: TextStyle(fontFamily: "cairo")),
                        selected: !_showFavoritesOnly,
                        selectedColor: Colors.green.withOpacity(0.2),
                        onSelected: (val) {
                          setState(() {
                            _showFavoritesOnly = false;
                            _visibleCount = _pageSize;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('المفضلة', style: TextStyle(fontFamily: "cairo")),
                        selected: _showFavoritesOnly,
                        selectedColor: Colors.green.withOpacity(0.2),
                        onSelected: (val) {
                          setState(() {
                            _showFavoritesOnly = true;
                            _visibleCount = _pageSize;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(
                    height: context.isTab ? 20 : 15),
              ),

              if (isInitialLoading)
                SliverToBoxAdapter(
                  child: Center(
                    child: KLoading.progressIOSIndicator(context: context),
                  ),
                ),

              if (!isInitialLoading && itemCount == 0)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text("لا توجد بيانات متاحة حالياً.", style: TextStyle(fontFamily: "cairo")),
                    ),
                  ),
                ),

              if (itemCount > 0)
                SliverToBoxAdapter(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: itemCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final item = filteredRadios[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, "/QuranRadioPlayerView",
                              arguments: QuranRadioPlayerArgs(
                                  title: item.name.toString() ?? "",
                                  streamUrl: item.url.toString() ?? ""));
                        },
                        child: Card(
                          elevation: 4,
                          color: AppThemeColors.cardBackgroundColor(context),
                          shape: BeveledRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(15)),
                          child: Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/icons/radio.png",
                                        height: context.isTab ? 60.h : 30,
                                      ),
                                      const SizedBox(height: 8),
                                      Flexible(
                                        child: TextWidget(
                                          color: isDark
                                              ? KColors.scoColor
                                              : KColors.primary2Color,
                                          fontWeight: FontWeight.w600,
                                          maxLines: 1,
                                          fontSize: context.isTab ? 7.sp : 10.sp,
                                          title: item.name.toString() ?? "",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                left: 4,
                                child: InkWell(
                                  onTap: () => _toggleFavorite(item.url.toString() ?? ""),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      _favUrls.contains(item.url.toString()) ? Icons.favorite : Icons.favorite_border,
                                      color: _favUrls.contains(item.url.toString()) ? Colors.red : Colors.grey.withOpacity(0.5),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Loader صغير تحت لما نزود الدُفعات
              if (_isLoadingMore && itemCount > 0 && itemCount < total)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                        child: KLoading.progressIOSIndicator(context: context)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
