import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/communities_cubit.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/communities_state.dart';

class CommunityStatisticsScreen extends StatefulWidget {
  const CommunityStatisticsScreen({super.key});

  @override
  State<CommunityStatisticsScreen> createState() => _CommunityStatisticsScreenState();
}

class _CommunityStatisticsScreenState extends State<CommunityStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CommunitiesCubit>().getUsersStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات المستخدمين'),
        centerTitle: true,
      ),
      body: BlocBuilder<CommunitiesCubit, CommunitiesState>(
        builder: (context, state) {
          if (state is CommunitiesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CommunitiesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('حدث خطأ', style: TextStyle(fontSize: 18.sp, color: Colors.red)),
                  SizedBox(height: 8.h),
                  Text(state.message),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<CommunitiesCubit>().getUsersStatistics(),
                    child: const Text('إعادة المحاولة'),
                  )
                ],
              ),
            );
          }

          if (state is CommunitiesStatisticsLoaded) {
            final stats = state.statistics;
            final total = stats['total'] ?? 0;
            final maleCount = stats['male'] ?? 0;
            final femaleCount = stats['female'] ?? 0;
            final Map<String, int> locations = Map<String, int>.from(stats['locations'] ?? {});

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatCard('إجمالي المستخدمين', total.toString(), Icons.people, Colors.blue),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('الرجال', maleCount.toString(), Icons.man, Colors.blueAccent)),
                      SizedBox(width: 16.w),
                      Expanded(child: _buildStatCard('النساء', femaleCount.toString(), Icons.woman, Colors.pinkAccent)),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text('التوزيع الجغرافي', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),
                  if (locations.isEmpty)
                    Center(child: Text('لا توجد بيانات للمواقع بعد', style: TextStyle(color: Colors.grey, fontSize: 16.sp)))
                  else
                    ...locations.entries.map((e) => _buildLocationTile(e.key, e.value)).toList(),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(icon, size: 48.w, color: color),
            SizedBox(height: 8.h),
            Text(value, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 4.h),
            Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTile(String location, int count) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        leading: Icon(Icons.location_on, color: KColors.primaryColor),
        title: Text(location, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: KColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text('$count مستخدم', style: TextStyle(color: KColors.primaryColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
