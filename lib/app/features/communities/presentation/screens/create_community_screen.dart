import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/communities_cubit.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/communities_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:another_flushbar/flushbar.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedType = 'حفظ قرآن';
  String _selectedTargetGender = 'both';

  final List<Map<String, String>> _targetGenders = [
    {'value': 'both', 'label': 'للجميع (رجال ونساء)'},
    {'value': 'male', 'label': 'للرجال فقط'},
    {'value': 'female', 'label': 'للنساء فقط'},
  ];

  final List<String> _types = [
    'حفظ قرآن',
    'تجويد',
    'تفسير',
    'أذكار',
    'أخرى',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<CommunitiesCubit>().createCommunity(
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
            communityType: _selectedType,
            targetGender: _selectedTargetGender,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء مجتمع جديد'),
        centerTitle: true,
      ),
      body: BlocListener<CommunitiesCubit, CommunitiesState>(
        listener: (context, state) {
          if (state is CommunityActionSuccess) {
            Flushbar(
              message: 'تم إنشاء المجتمع بنجاح',
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ).show(context).then((value) => Navigator.pop(context));
          } else if (state is CommunitiesError) {
            Flushbar(
              message: 'حدث خطأ: ${state.message}',
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ).show(context);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اسم المجتمع', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'أدخل اسم المجتمع',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
                ),
                SizedBox(height: 16.h),
                Text('الوصف', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'وصف مختصر للمجتمع',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
                SizedBox(height: 16.h),
                Text('نوع المجتمع', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  items: _types.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedType = val;
                    });
                  },
                ),
                SizedBox(height: 16.h),
                Text('الجمهور المستهدف', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: _selectedTargetGender,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  items: _targetGenders.map((gender) {
                    return DropdownMenuItem(value: gender['value'], child: Text(gender['label']!));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedTargetGender = val;
                      });
                    }
                  },
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
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KColors.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text('إنشاء', style: TextStyle(fontSize: 18.sp, color: Colors.white)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
