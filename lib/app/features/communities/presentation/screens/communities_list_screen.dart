import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/communities_cubit.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/communities_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:muslimdaily/app/core/utils/constent/router.dart';

import 'package:muslimdaily/app/features/communities/presentation/screens/community_profile_setup_screen.dart';
import 'package:muslimdaily/app/features/communities/presentation/screens/explore_communities_screen.dart';
import 'package:muslimdaily/app/features/communities/presentation/screens/community_statistics_screen.dart';
import 'package:muslimdaily/app/features/communities/presentation/screens/join_community_screen.dart';
import 'package:shimmer/shimmer.dart';

class CommunitiesListScreen extends StatefulWidget {
  const CommunitiesListScreen({super.key});

  @override
  State<CommunitiesListScreen> createState() => _CommunitiesListScreenState();
}

class _CommunitiesListScreenState extends State<CommunitiesListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CommunitiesCubit>().getUserCommunities();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunitiesCubit, CommunitiesState>(
      builder: (context, state) {
        if (state is CommunitiesProfileRequired) {
          return const CommunityProfileSetupScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('المجتمعات والحلقات'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'تسجيل الخروج',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('تسجيل الخروج'),
                      content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من المجتمعات وحذف بياناتك من هذا الجهاز؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<CommunitiesCubit>().logout();
                          },
                          child: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.add_link_rounded),
                tooltip: 'الانضمام بكود الدعوة',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JoinCommunityScreen()),
                  );
                },
              ),
              FutureBuilder(
                future: context.read<CommunitiesCubit>().repository.getProfile(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!.fold(
                      (failure) => const SizedBox.shrink(),
                      (profile) {
                        if (profile['is_teacher'] == 'true') {
                          return IconButton(
                            icon: const Icon(Icons.bar_chart),
                            tooltip: 'الإحصائيات',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CommunityStatisticsScreen()),
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Profile Header Section
              FutureBuilder(
                future: context.read<CommunitiesCubit>().repository.getProfile(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  
                  return snapshot.data!.fold(
                    (failure) => const SizedBox.shrink(),
                    (profile) {
                      final name = profile['name'] ?? 'مستخدم';
                      final isTeacher = profile['is_teacher'] == 'true';
                      final gender = profile['gender'] ?? 'male';

                      FaIconData userIcon;
                      String roleName;
                      if (isTeacher) {
                        userIcon = FontAwesomeIcons.chalkboardUser;
                        roleName = 'معلم';
                      } else if (gender == 'female') {
                        userIcon = FontAwesomeIcons.personDress;
                        roleName = 'طالبة';
                      } else {
                        userIcon = FontAwesomeIcons.person;
                        roleName = 'طالب';
                      }

                      final isDark = Theme.of(context).brightness == Brightness.dark;

                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                          ],
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.r),
                            bottomRight: Radius.circular(20.r),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30.r,
                              backgroundColor: KColors.primaryColor.withOpacity(0.1),
                              child: FaIcon(userIcon, color: KColors.primaryColor, size: 28.sp),
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'أهلاً بك، $name',
                                    style: TextStyle(
                                      fontSize: 18.sp, 
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: isTeacher ? Colors.orange.withOpacity(0.1) : KColors.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      roleName,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: isTeacher ? Colors.orange.shade800 : KColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              
              // Communities List Section
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state is CommunitiesLoading) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                            child: Container(
                              height: 80.h,
                              margin: EdgeInsets.only(bottom: 12.h),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[850] : Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is CommunitiesError) {
                      return Center(
                        child: Text('حدث خطأ: ${state.message}',
                            style: TextStyle(color: Colors.red, fontSize: 16.sp)),
                      );
                    } else if (state is CommunitiesLoaded) {
                      if (state.communities.isEmpty) {
                        return RefreshIndicator(
                          color: KColors.primaryColor,
                          onRefresh: () async {
                            context.read<CommunitiesCubit>().getUserCommunities();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(20.w),
                                      decoration: BoxDecoration(
                                        color: KColors.primaryColor.withOpacity(0.05),
                                        shape: BoxShape.circle,
                                      ),
                                      child: FaIcon(FontAwesomeIcons.usersSlash, size: 60.sp, color: KColors.primaryColor.withOpacity(0.5)),
                                    ),
                                    SizedBox(height: 24.h),
                                    Text(
                                      'لا توجد مجتمعات مسجلة',
                                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                                    ),
                                    SizedBox(height: 10.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                                      child: Text(
                                        'ابدأ رحلتك الآن وانضم إلى الحلقات والمجتمعات القرآنية المتاحة',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14.sp, color: Colors.grey, height: 1.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      
                      return RefreshIndicator(
                        color: KColors.primaryColor,
                        onRefresh: () async {
                          context.read<CommunitiesCubit>().getUserCommunities();
                        },
                        child: ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: state.communities.length,
                        itemBuilder: (context, index) {
                          final community = state.communities[index];
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                if (!isDark)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.r),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context, 
                                    Routes.communityDetails, 
                                    arguments: community,
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Row(
                                    children: [
                                      Hero(
                                        tag: 'community_avatar_${community.id}',
                                        child: Container(
                                          width: 50.w,
                                          height: 50.w,
                                          decoration: BoxDecoration(
                                            color: KColors.primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: Center(
                                            child: FaIcon(FontAwesomeIcons.usersRectangle, color: KColors.primaryColor, size: 24.sp),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    community.name,
                                                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (index == 0) // Demo badge for the first item
                                                  Container(
                                                    margin: EdgeInsets.only(right: 8.w),
                                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(4.r),
                                                    ),
                                                    child: Text('جديد', style: TextStyle(color: Colors.red, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(height: 4.h),
                                            Row(
                                              children: [
                                                Icon(Icons.label_outline, size: 14.sp, color: Colors.grey),
                                                SizedBox(width: 4.w),
                                                Text(
                                                  community.communityType ?? 'مجتمع عام',
                                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey.shade400),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'explore',
            backgroundColor: KColors.primaryColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExploreCommunitiesScreen()),
              );
            },
            icon: const Icon(Icons.explore),
            label: const Text('استكشاف المجتمعات'),
          ),
        );
      },
    );
  }
}
