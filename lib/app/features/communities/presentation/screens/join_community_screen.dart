import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/communities_cubit.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/communities_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:another_flushbar/flushbar.dart';

class JoinCommunityScreen extends StatefulWidget {
  const JoinCommunityScreen({super.key});

  @override
  State<JoinCommunityScreen> createState() => _JoinCommunityScreenState();
}

class _JoinCommunityScreenState extends State<JoinCommunityScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _join() {
    final code = _codeController.text.trim();
    if (code.isNotEmpty) {
      context.read<CommunitiesCubit>().joinCommunity(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الانضمام لمجتمع'),
        centerTitle: true,
      ),
      body: BlocListener<CommunitiesCubit, CommunitiesState>(
        listener: (context, state) {
          if (state is CommunityActionSuccess) {
            Flushbar(
              message: 'تم الانضمام بنجاح',
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ).show(context).then((value) => Navigator.pop(context));
          } else if (state is CommunitiesError) {
            Flushbar(
              message: 'كود غير صحيح أو حدث خطأ: ${state.message}',
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ).show(context);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link, size: 80.sp, color: KColors.primaryColor),
              SizedBox(height: 24.h),
              Text(
                'أدخل كود الدعوة للانضمام للمجتمع',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: _codeController,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.sp, letterSpacing: 2),
                decoration: InputDecoration(
                  hintText: 'ABCDEF12',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: BlocBuilder<CommunitiesCubit, CommunitiesState>(
                  builder: (context, state) {
                    if (state is CommunityActionLoading) {
                      return ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KColors.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: const CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    return ElevatedButton(
                      onPressed: _join,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('انضمام', style: TextStyle(fontSize: 18.sp, color: Colors.white)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
