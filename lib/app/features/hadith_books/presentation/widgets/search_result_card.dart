import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

import '../../../../core/utils/style/k_color.dart';
import '../../controllers/books_controller.dart';
import '../../controllers/extensions/books_getters_extension.dart';
import '../../data/models/ar_hadith_model.dart';

class SearchResultCard extends StatelessWidget {
  final ARHadithModel hadith;
  final String searchQuery;

  const SearchResultCard({
    super.key,
    required this.hadith,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final baseColor = KColors.primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8F9FA),
                ],
        ),
        border: Border.all(
          color: baseColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            // Navigate to hadith detail
             BooksController.instance.navigateToHadith(hadith);
          },
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Book Name & Hadith Number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 16.sp,
                            color: baseColor,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              hadith.bookName,
                              style: TextStyle(
                  fontFamily: "cairo",
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: baseColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '#${hadith.hadithNumber}',
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Hadith Text with Highlighting
                _buildHighlightedText(
                  hadith.hadithText,
                  searchQuery,
                  isDark,
                ),

                // Grade Badge (if available)
                if (hadith.grade1 != null && hadith.grade1!.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      hadith.grade1!,
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],

                // Narrator/Chapter Info (if available)
                if (hadith.babName != null && hadith.babName!.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14.sp,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          hadith.babName!,
                          style: TextStyle(
                  fontFamily: "cairo",
                            fontSize: 12.sp,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query, bool isDark) {
    if (query.isEmpty) {
      return Text(
        text.length > 200 ? '${text.substring(0, 200)}...' : text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'naskh',
          height: 1.7,
          fontSize: 15.sp,
          color: isDark ? Colors.grey[200] : Colors.grey[900],
          fontWeight: FontWeight.w500,
        ),
      );
    }

    // Remove diacritics for comparison
    final textWithoutDiacritics = _removeDiacritics(text);
    final queryWithoutDiacritics = _removeDiacritics(query);

    // Find all matches
    final matches = <Match>[];
    final lowerText = textWithoutDiacritics.toLowerCase();
    final lowerQuery = queryWithoutDiacritics.toLowerCase();
    
    int index = 0;
    while (index < lowerText.length) {
      final matchIndex = lowerText.indexOf(lowerQuery, index);
      if (matchIndex == -1) break;
      
      matches.add(Match(matchIndex, matchIndex + lowerQuery.length));
      index = matchIndex + lowerQuery.length;
    }

    if (matches.isEmpty) {
      return Text(
        text.length > 200 ? '${text.substring(0, 200)}...' : text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'naskh',
          height: 1.7,
          fontSize: 15.sp,
          color: isDark ? Colors.grey[200] : Colors.grey[900],
          fontWeight: FontWeight.w500,
        ),
      );
    }

    // Build TextSpan with highlights
    final spans = <TextSpan>[];
    int currentIndex = 0;
    
    // Show context around first match
    final firstMatch = matches.first;
    final contextStart = (firstMatch.start - 50).clamp(0, text.length);
    final contextEnd = (firstMatch.end + 150).clamp(0, text.length);
    
    String displayText = text.substring(contextStart, contextEnd);
    if (contextStart > 0) displayText = '...$displayText';
    if (contextEnd < text.length) displayText = '$displayText...';
    
    // Adjust match positions for the substring
    final adjustedMatches = matches
        .where((m) => m.start >= contextStart && m.end <= contextEnd)
        .map((m) => Match(
              m.start - contextStart + (contextStart > 0 ? 3 : 0),
              m.end - contextStart + (contextStart > 0 ? 3 : 0),
            ))
        .toList();

    for (final match in adjustedMatches) {
      // Add text before match
      if (currentIndex < match.start) {
        spans.add(TextSpan(
          text: displayText.substring(currentIndex, match.start),
          style: TextStyle(
            fontFamily: 'naskh',
            height: 1.7,
            fontSize: 15.sp,
            color: isDark ? Colors.grey[200] : Colors.grey[900],
            fontWeight: FontWeight.w500,
          ),
        ));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: displayText.substring(match.start, match.end),
        style: TextStyle(
          fontFamily: 'naskh',
          height: 1.7,
          fontSize: 15.sp,
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          backgroundColor: KColors.primaryColor.withOpacity(0.3),
        ),
      ));
      
      currentIndex = match.end;
    }
    
    // Add remaining text
    if (currentIndex < displayText.length) {
      spans.add(TextSpan(
        text: displayText.substring(currentIndex),
        style: TextStyle(
          fontFamily: 'naskh',
          height: 1.7,
          fontSize: 15.sp,
          color: isDark ? Colors.grey[200] : Colors.grey[900],
          fontWeight: FontWeight.w500,
        ),
      ));
    }

    return RichText(
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }

  String _removeDiacritics(String text) {
    return text.replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065E\u0670]'), '');
  }
}

class Match {
  final int start;
  final int end;

  Match(this.start, this.end);
}
