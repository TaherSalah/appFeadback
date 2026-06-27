import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/features/communities/domain/entities/community.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/community_details_cubit.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/community_details_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class CommunityDetailsScreen extends StatefulWidget {
  final Community community;

  const CommunityDetailsScreen({super.key, required this.community});

  @override
  State<CommunityDetailsScreen> createState() => _CommunityDetailsScreenState();
}

class _CommunityDetailsScreenState extends State<CommunityDetailsScreen> {

  @override
  void initState() {
    super.initState();
    context.read<CommunityDetailsCubit>().loadDetails(widget.community.id);
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.community.name),
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share community code
              showDialog(
                context: context,
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: KColors.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.people_alt_rounded, color: KColors.primaryColor, size: 40.w),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'دعوة للحصول على الأجر',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'شارك هذا الكود مع من تحب لينضموا إلى هذا المجتمع وتشاركهم الأجر.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey, height: 1.5),
                          ),
                          SizedBox(height: 24.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: KColors.primaryColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    widget.community.inviteCode,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                      color: KColors.primaryColor,
                                      fontFamily: 'monospace',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, color: Colors.grey),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: widget.community.inviteCode));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم نسخ الكود بنجاح!'), backgroundColor: Colors.green),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                  ),
                                  child: Text('إغلاق', style: TextStyle(color: Colors.grey, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Share.share('انضم إلينا في مجتمع "${widget.community.name}" على تطبيق رفيق المسلم اليومي!\n\nاستخدم كود الدعوة التالي للانضمام:\n${widget.community.inviteCode}');
                                  },
                                  icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                                  label: Text('مشاركة', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: KColors.primaryColor,
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CommunityDetailsCubit, CommunityDetailsState>(
        builder: (context, state) {
          if (state is CommunityDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CommunityDetailsError) {
            return Center(child: Text('حدث خطأ: ${state.message}'));
          } else if (state is CommunityDetailsLoaded) {
            if (state.meetings.isEmpty) {
              return Center(child: Text('لا توجد حلقات قادمة أو سابقة', style: TextStyle(color: Colors.grey, fontSize: 16.sp)));
            }
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.meetings.length,
              itemBuilder: (context, index) {
                final meeting = state.meetings[index];
                final isJoinable = meeting.meetingDate.add(const Duration(hours: 3)).isAfter(DateTime.now());
                
                final isDark = Theme.of(context).brightness == Brightness.dark;
                
                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          width: 6.w,
                          child: Container(color: KColors.primaryColor),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          spacing: 8.w,
                                          runSpacing: 4.h,
                                          children: [
                                            Text(meeting.title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, height: 1.2)),
                                            if (meeting.targetGender != 'both')
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                                decoration: BoxDecoration(
                                                  color: meeting.targetGender == 'male' ? Colors.blue.withOpacity(0.1) : Colors.pink.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6.r),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      meeting.targetGender == 'male' ? '👨' : '👩',
                                                      style: TextStyle(fontSize: 10.sp),
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                      meeting.targetGender == 'male' ? 'رجال' : 'نساء',
                                                      style: TextStyle(
                                                        fontFamily: "cairo",
                                                        color: meeting.targetGender == 'male' ? Colors.blue : Colors.pink,
                                                        fontSize: 11.sp,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time_filled_rounded, size: 16.w, color: KColors.primaryColor.withOpacity(0.8)),
                                            SizedBox(width: 6.w),
                                            Text(
                                              DateFormat('yyyy/MM/dd hh:mm a').format(meeting.meetingDate.toLocal()),
                                              style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.w500,),
                                            ),
                                          ],
                                        ),
                                        if (meeting.teacherName != null && meeting.teacherName!.isNotEmpty) ...[
                                          SizedBox(height: 8.h),
                                          Row(
                                            children: [
                                              Icon(Icons.person_pin_rounded, size: 18.w, color: KColors.primaryColor),
                                              SizedBox(width: 6.w),
                                              Text('تقديم: ${meeting.teacherName}', style: TextStyle(fontSize: 13.sp, color: KColors.primaryColor, fontWeight: FontWeight.bold,fontFamily: "me",)),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (meeting.meetUrl != null && isJoinable)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: KColors.primaryColor.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        gradient: LinearGradient(
                                          colors: [
                                            KColors.primaryColor.withOpacity(0.8),
                                            KColors.primaryColor,
                                          ],
                                        ),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () => _launchUrl(meeting.meetUrl!),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('انضم الآن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                                            SizedBox(width: 4.w),
                                            Icon(Icons.video_camera_front_rounded, color: Colors.white, size: 18.w),
                                          ],
                                        ),
                                      ),
                                    )
                                  else if (!isJoinable)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                      decoration: BoxDecoration(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, borderRadius: BorderRadius.circular(12.r)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.history_rounded, size: 16.w, color: Colors.grey),
                                          SizedBox(width: 4.w),
                                          Text('منتهية', style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              if (meeting.reportContent != null && meeting.reportContent!.isNotEmpty) ...[
                                SizedBox(height: 16.h),
                                Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                                SizedBox(height: 8.h),
                          Text('📝 تقرير الحلقة:', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          SizedBox(height: 8.h),
                          SelectableText(meeting.reportContent!, style: TextStyle(fontSize: 14.sp)),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: meeting.reportContent!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('تم نسخ التقرير بنجاح'), duration: Duration(seconds: 2)),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, size: 20, color: Colors.grey),
                                onPressed: () async {
                                  final shareText = '${meeting.title}\n${meeting.teacherName != null ? 'تقديم: ${meeting.teacherName}\n' : ''}\n${meeting.reportContent!}';
                                  try {
                                    final box = context.findRenderObject() as RenderBox?;
                                    await Share.share(
                                      shareText,
                                      sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
                                    );
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('حدث خطأ في المشاركة: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
