import 'package:flutter/material.dart';
import 'package:muslimdaily/app/core/utils/style/app_theme_colors.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:showcaseview/showcaseview.dart';
import '../../../core/shard/exports/all_exports.dart';
import '../data/model/user_guide_item.dart';
import '../data/source/user_guide_data.dart';
import 'user_guide_detail_screen.dart';

class UserGuideListScreen extends StatefulWidget {
  const UserGuideListScreen({super.key});

  @override
  State<UserGuideListScreen> createState() => _UserGuideListScreenState();
}

class _UserGuideListScreenState extends State<UserGuideListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<UserGuideItem> _filteredItems = UserGuideData.items;
  List<String> _favoriteIds = [];

  // Voice Search
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  final Map<UserGuideCategory, String> _categoryNames = {
    UserGuideCategory.worship: "العبادات",
    UserGuideCategory.finances: "الزكاة والمال",
    UserGuideCategory.kids: "الأطفال",
    UserGuideCategory.companion: "الرفيق",
    UserGuideCategory.utilities: "الأدوات",
    UserGuideCategory.support: "الدعم",
  };

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: UserGuideCategory.values.length + 2, vsync: this);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteIds = prefs.getStringList('favorite_guides') ?? [];
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = UserGuideData.items;
      } else {
        _filteredItems = UserGuideData.items
            .where((item) =>
                item.title.toLowerCase().contains(query.toLowerCase()) ||
                item.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _searchController.text = val.recognizedWords;
            _onSearchChanged(val.recognizedWords);
            if (val.hasConfidenceRating && val.confidence > 0) {
              _isListening = false;
              _speech.stop();
            }
          }),
          localeId: 'ar_SA',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "دليل المستخدم",
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "بحث عن ميزة...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.red : Colors.green,
                        ),
                        onPressed: _listen,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.green,
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    const Tab(text: "الكل"),
                    const Tab(text: "المفضلة"),
                    ...UserGuideCategory.values.map(
                      (cat) => Tab(text: _categoryNames[cat]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFilteredList(_filteredItems), // "All" tab
            _buildFilteredList(_filteredItems
                .where((item) => _favoriteIds.contains(item.id))
                .toList()), // Favorites tab
            ...UserGuideCategory.values.map(
              (cat) => _buildFilteredList(
                _filteredItems.where((item) => item.category == cat).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredList(List<UserGuideItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "لا توجد نتائج",
              style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildFeatureCard(context, items[index]);
      },
    );
  }

  Widget _buildFeatureCard(BuildContext context, UserGuideItem item) {
    final isFavorite = _favoriteIds.contains(item.id);
    return Card(
      elevation: 4,
      color: AppThemeColors.cardBackgroundColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            item.requiresInternet ? Icons.wifi : Icons.wifi_off,
            color: item.requiresInternet ? Colors.blue : Colors.green,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.title,
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (item.isNew)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'جديد',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (isFavorite)
              const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            _buildStatusBadge(item.requiresInternet),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(fontSize: 13),
          ),
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowCaseWidget(
                builder: (context) => UserGuideDetailScreen(item: item),
              ),
            ),
          );
          _loadFavorites();
        },
      ),
    );
  }

  Widget _buildStatusBadge(bool requiresInternet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: requiresInternet
            ? Colors.blue.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: requiresInternet ? Colors.blue : Colors.green,
          width: 1,
        ),
      ),
      child: Text(
        requiresInternet ? 'إنترنت' : 'أوفلاين',
        style: TextStyle(
          fontSize: 10,
          color: requiresInternet ? Colors.blue : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
