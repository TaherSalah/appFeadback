import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/charity_models.dart';
import 'services/charity_service.dart';
import 'services/charity_pdf_service.dart';
import 'AddCharityScreen.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF1A1F36) : const Color(0xFFF5F7FA),
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
          preferredSize: Size.fromHeight(
              MediaQuery.sizeOf(context).width > 600 ? 70 : 50),
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
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize:
                MediaQuery.sizeOf(context).width > 600 ? 12.sp : 18.sp,
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
                  ? const Center(child: CircularProgressIndicator())
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
    final isSelected = _filterCategory == category;
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
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

  Widget _buildDonationCard(CharityDonation donation, bool isDark) {
    return Dismissible(
      key: Key(donation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'تأكيد الحذف',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'هل أنت متأكد من حذف هذه الصدقة؟',
              style: GoogleFonts.cairo(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('إلغاء', style: GoogleFonts.cairo()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('حذف', style: GoogleFonts.cairo()),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await _charityService.deleteDonation(donation.id);
        _loadDonations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم حذف الصدقة',
                style: GoogleFonts.cairo(),
              ),
            ),
          );
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
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D3748) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Emoji
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  donation.category.emoji,
                  style: TextStyle(fontSize: 24.sp),
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
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${donation.date.day}/${donation.date.month}/${donation.date.year}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: Colors.grey,
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
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF3B82F6),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (donation.notes != null &&
                                  donation.notes!.isNotEmpty)
                                Text(' • ',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12.sp)),
                            ],
                            if (donation.notes != null &&
                                donation.notes!.isNotEmpty)
                              Expanded(
                                child: Text(
                                  donation.notes!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.sp,
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
              Text(
                '${donation.amount.toStringAsFixed(0)} ${donation.currency}',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📭', style: TextStyle(fontSize: 80.sp)),
          SizedBox(height: 16.h),
          Text(
            'لا توجد صدقات بعد',
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ابدأ بإضافة أول صدقة لك',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
