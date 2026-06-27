import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/features/communities/domain/repositories/communities_repository.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/communities_cubit.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/explore_communities_cubit.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/explore_communities_state.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/extensions/context_extension.dart';

class ExploreCommunitiesScreen extends StatelessWidget {
  const ExploreCommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExploreCommunitiesCubit(
        repository: GetIt.instance<CommunitiesRepository>(),
      )..loadAvailableCommunities(),
      child: const _ExploreCommunitiesView(),
    );
  }
}

class _ExploreCommunitiesView extends StatelessWidget {
  const _ExploreCommunitiesView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          context.isTab ? 70 : 50,
        ),
        child: AppBar(
          leading: CupertinoNavigationBarBackButton(
            color:context.isDark ? Colors.white : Colors.black,
          ),
          centerTitle: true,
          title: Text(
            'استكشاف المقرأة القرآنية',
            style: TextStyle(
              fontFamily: "cairo",
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: context.isTab ? 12.sp : 18.sp,
            ),
          ),
        ),
      ),

      body: BlocConsumer<ExploreCommunitiesCubit, ExploreCommunitiesState>(
        listener: (context, state) {
          if (state is ExploreCommunityJoinSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم الانضمام للمجتمع بنجاح!')),
            );
            // Refresh main communities list
            context.read<CommunitiesCubit>().getUserCommunities();
            Navigator.pop(context);
          } else if (state is ExploreCommunitiesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ExploreCommunitiesLoading || state is ExploreCommunityJoinLoading) {
            return _buildLoading();
          }

          if (state is ExploreCommunitiesLoaded) {
            final communities = state.communities;

            if (communities.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64.w, color: Colors.grey),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد مجتمعات متاحة حالياً',
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: communities.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final community = communities[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: KColors.primaryColor.withOpacity(0.1),
                              child: Icon(Icons.school, color: KColors.primaryColor),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    community.name,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (community.targetGender != 'both')
                                    Text(
                                      community.targetGender == 'male' ? '👨 للرجال فقط' : '👩 للنساء فقط',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: community.targetGender == 'male' ? Colors.blue : Colors.pink,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Builder(
                              builder: (context) {
                                final isJoined = state.joinedCommunityIds.contains(community.id);
                                return ElevatedButton(
                                  onPressed: isJoined ? null : () {
                                    context.read<ExploreCommunitiesCubit>().joinCommunity(community.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isJoined ? Colors.grey : KColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                  ),
                                  child: Text(isJoined ? 'تم الانضمام' : 'انضمام'),
                                );
                              }
                            ),
                          ],
                        ),
                        if (community.description != null && community.description!.isNotEmpty) ...[
                          SizedBox(height: 12.h),
                          Text(
                            community.description!,
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Card(
            color: isDark ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            child: SizedBox(height: 100.h),
          ),
        );
      },
    );
  }
}
