import 'dart:ui' as ui;

import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

import '../../core/utils/style/k_helper.dart';
import '../../core/widgets/KLoading.dart';
import 'AddCharityScreen.dart';
import 'models/charity_models.dart';
import 'services/charity_pdf_service.dart';
import 'services/charity_service.dart';

class CharityHistoryScreen extends StatefulWidget {
  const CharityHistoryScreen({super.key});

  @override
  State<CharityHistoryScreen> createState() => _CharityHistoryScreenState();
}

class _CharityHistoryScreenState extends State<CharityHistoryScreen> {
  final CharityService _charityService = CharityService();
  List<CharityDonation> _donations = [];
  CharityCategory? _filterCategory;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() => _loading = true);
    await _charityService.init();
    setState(() {
      _donations = _charityService.getAllDonations();
      _loading = false;
    });
  }

  List<CharityDonation> get _filteredDonations {
    if (_filterCategory == null) return _donations;
    return _donations.where((d) => d.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // backgroundColor:
        //     isDark ? const Color(0xFF1A1F36) : const Color(0xFFF5F7FA),
        // appBar: AppBar(
        //   title: Text(
        //     'سجل الصدقات 📜',
        //     style: GoogleFonts.cairo(
        //       fontWeight: FontWeight.bold,
        //       fontSize: 20.sp,
        //     ),
        //   ),
        //   centerTitle: true,
        //   elevation: 0,
        //   backgroundColor: Colors.transparent,
        //   actions: [
        //     IconButton(
        //       icon: const Icon(Icons.picture_as_pdf_outlined),
        //       onPressed: () async {
        //         final donations = _charityService.getAllDonations();
        //         // Assuming calculateStats() is a method in CharityService that returns relevant statistics
        //         // If not implemented, this line will cause a compile-time error.
        //         // For the purpose of this edit, it's included as per instruction.
        //         final stats = _charityService.calculateStats();
        //         await CharityPdfService.generateDonationsReport(
        //             donations, stats);
        //       },
        //       tooltip: 'تصدير PDF',
        //     ),
        //     SizedBox(width: 8.w),
        //   ],
        // ),
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(context.isTab ? 70 : 50),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () async {
                  final donations = _charityService.getAllDonations();
                  // Assuming calculateStats() is a method in CharityService that returns relevant statistics
                  // If not implemented, this line will cause a compile-time error.
                  // For the purpose of this edit, it's included as per instruction.
                  final stats = _charityService.calculateStats();
                  await CharityPdfService.generateDonationsReport(
                      donations, stats);
                },
                tooltip: 'تصدير PDF',
              ),
            ],
            centerTitle: true,
            title: Text(
              'سجل الصدقات ',
                 style: TextStyle(
                          fontFamily: "cairo",
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                    context.isTab ? 12.sp : 18.sp,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // Filter chips
            SizedBox(
              height: 50.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  _buildFilterChip('الكل', null, isDark),
                  ...CharityCategory.values.map(
                    (c) => _buildFilterChip(c.arabicName, c, isDark),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // قائمة الصدقات
            Expanded(
              child: _loading
                  ?  Center(child:  KLoading.progressIOSIndicator(context: context))
                  : _filteredDonations.isEmpty
                      ? _buildEmptyState(isDark)
                      : RefreshIndicator(
                          onRefresh: _loadDonations,
                          child: ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: _filteredDonations.length,
                            itemBuilder: (context, index) {
                              return _buildDonationCard(
                                _filteredDonations[index],
                                isDark,
                                index,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, CharityCategory? category, bool isDark) {
    bool isTab = context.isTab;
    final isSelected = _filterCategory == category;
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: FilterChip(
        label: Text(
          label,
             style: TextStyle(
                          fontFamily: "cairo",
            fontSize: isTab ? 9.5.sp : 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : null,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterCategory = selected ? category : null;
          });
        },
        selectedColor: const Color(0xFF10B981),
        backgroundColor: isDark ? const Color(0xFF2D3748) : Colors.white,
      ),
    );
  }

  Widget _buildDonationCard(CharityDonation donation, bool isDark, int index) {
    bool isTab = context.isTab;
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      delay: Duration(milliseconds: 100 * (index % 10)), // Staggered entry
      child: Dismissible(
        key: Key(donation.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24.r),
          ),
          alignment: Alignment.centerLeft,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await _showDeleteDonationDialog(context);
        },

        onDismissed: (direction) async {
          await _charityService.deleteDonation(donation.id);
          _loadDonations();
          if (mounted) {
            KHelper.showSuccess(message: "تم حذف الصدقة");

          }
        },
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddCharityScreen(donation: donation),
              ),
            ).then((_) => _loadDonations());
          },
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFFD4AF37).withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      // Emoji Container
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          donation.category.emoji,
                          style: TextStyle(fontSize: isTab ? 20.sp : 24.sp),
                        ),
                      ),

                      SizedBox(width: 16.w),

                      // التفاصيل
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              donation.category.arabicName,
                                 style: TextStyle(
                          fontFamily: "cairo",
                                fontSize: isTab ? 10.sp : 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '${donation.date.day}/${donation.date.month}/${donation.date.year}',
                                 style: TextStyle(
                          fontFamily: "cairo",
                                fontSize: isTab ? 8.sp : 12.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                            if ((donation.notes != null &&
                                    donation.notes!.isNotEmpty) ||
                                donation.paymentMethod != null)
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Row(
                                  children: [
                                    if (donation.paymentMethod != null) ...[
                                      Text(
                                        '${donation.paymentMethod!.icon} ${donation.paymentMethod!.arabicName}',
                                           style: TextStyle(
                          fontFamily: "cairo",
                                          fontSize: isTab ? 8.sp : 11.sp,
                                          color: const Color(0xFF3B82F6),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (donation.notes != null &&
                                          donation.notes!.isNotEmpty)
                                        Text(' • ',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize:
                                                    isTab ? 9.sp : 12.sp)),
                                    ],
                                    if (donation.notes != null &&
                                        donation.notes!.isNotEmpty)
                                      Expanded(
                                        child: Text(
                                          donation.notes!,
                                             style: TextStyle(
                          fontFamily: "cairo",
                                            fontSize: isTab ? 9.sp : 12.sp,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // المبلغ
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${donation.amount.toStringAsFixed(0)}',
                               style: TextStyle(
                          fontFamily: "cairo",
                              fontSize: isTab ? 12.sp : 20.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          Text(
                            donation.currency,
                               style: TextStyle(
                          fontFamily: "cairo",
                              fontSize: isTab ? 8.sp : 10.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<bool> _showDeleteDonationDialog(BuildContext context) async {
    final bool isDark = context.isDark;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Body
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 20.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: isDark
                        ? [const Color(0xFF2B0B0B), const Color(0xFF200505)]
                        : [const Color(0xFFFFF2F2), const Color(0xFFFFE1E1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تأكيد الحذف',
                         style: TextStyle(
                          fontFamily: "cairo",
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'هل أنت متأكد من حذف هذه الصدقة؟\nلا يمكن التراجع عن هذه العملية.',
                         style: TextStyle(
                          fontFamily: "cairo",
                        fontSize: 13.sp,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),

                    // Info card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: Colors.red.withOpacity(0.06),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 18, color: Colors.red),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'سيتم حذف الصدقة نهائيًا من القائمة.',
                                 style: TextStyle(
                          fontFamily: "cairo",
                                fontSize: 12.5.sp,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 11.h),
                            ),
                            child: Text(
                              'إلغاء',
                                 style: TextStyle(
                          fontFamily: "cairo",
                                fontSize: 14.sp,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            icon: const Icon(Icons.delete_outline),
                            label: Text('حذف',    style: TextStyle(
                          fontFamily: "cairo",)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 11.h),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Top icon
              Positioned(
                top: -30.h,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.deepOrange],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.delete_forever_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? false;
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text('📭', style: TextStyle(fontSize: 80.sp)),
          // SizedBox(height: 16.h),
          Text(
            'لا توجد صدقات بعد',
               style: TextStyle(
                          fontFamily: "cairo",
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ابدأ بإضافة أول صدقة لك',
               style: TextStyle(
                          fontFamily: "cairo",
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
