import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/features/quran/pdf/data/quran_pdf_data.dart';

class PdfNavigationDialog extends StatefulWidget {
  const PdfNavigationDialog({super.key});

  @override
  State<PdfNavigationDialog> createState() => _PdfNavigationDialogState();
}

class _PdfNavigationDialogState extends State<PdfNavigationDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredSurahs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filteredSurahs = QuranPdfData.surahNames;
  }

  void _filterSurahs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSurahs = QuranPdfData.surahNames;
      } else {
        _filteredSurahs = QuranPdfData.surahNames
            .where((name) => name.contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: 500,
        child: Column(
          children: [
            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: Colors.teal,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.teal,
              tabs: const [
                Tab(text: 'السور'),
                Tab(text: 'الأجزاء'),
              ],
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Surah List
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'بحث عن سورة...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                          ),
                          onChanged: _filterSurahs,
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _filteredSurahs.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final surahName = _filteredSurahs[index];
                            final surahIndex =
                                QuranPdfData.surahNames.indexOf(surahName) + 1;
                            return ListTile(
                              title: Text(
                                '$surahIndex. $surahName',
                                style: TextStyle(
                  fontFamily: "cairo",
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                final page =
                                    QuranPdfData.getPageForSurah(surahIndex);
                                Navigator.pop(context, page);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // Juz List
                  ListView.separated(
                    itemCount: 30,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final juzIndex = index + 1;
                      return ListTile(
                        title: Text(
                          'الجزء $juzIndex',
                          style: TextStyle(
                  fontFamily: "cairo",fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          final page = QuranPdfData.getPageForJuz(juzIndex);
                          Navigator.pop(context, page);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
