import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/features/communities/presentation/cubit/communities_cubit.dart';

import '../../../../core/extensions/context_extension.dart';

class CommunityProfileSetupScreen extends StatefulWidget {
  const CommunityProfileSetupScreen({super.key});

  @override
  State<CommunityProfileSetupScreen> createState() => _CommunityProfileSetupScreenState();
}

class _CommunityProfileSetupScreenState extends State<CommunityProfileSetupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedGender = 'male';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final name = '$firstName $lastName'.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة الاسم الأول والثاني')),
      );
      return;
    }
    
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الهاتف')),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال بريد إلكتروني صالح')),
      );
      return;
    }

    final isExisting = await context.read<CommunitiesCubit>().saveProfile(
      name, 
      _selectedGender,
      email: email.isNotEmpty ? email : null,
      phone: phone,
      location: location.isNotEmpty ? location : null,
    );

    if (isExisting && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🎉 ', style: TextStyle(fontSize: 20)),
              Expanded(
                child: Text(
                  'مرحباً بعودتك أستاذ $name! تم استرجاع بياناتك وصلاحياتك بنجاح.',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isOptional = false,
    TextInputType? keyboardType,
    int? maxLength,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            counterText: '',
            labelText: label + (isOptional ? ' (اختياري)' : ''),
            labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
            prefixIcon: Container(
              padding: EdgeInsets.all(12.w),
              margin: EdgeInsets.only(left: 12.w, right: 12.w),
              decoration: BoxDecoration(
                color: KColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: KColors.primaryColor, size: 22.w),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 50.w, minHeight: 50.w),
            suffixIcon: suffixIcon,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(String gender, String title, String emoji, bool isDark) {
    final isSelected = _selectedGender == gender;
    final color = gender == 'male' ? Colors.blue.shade400 : Colors.pink.shade400;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          decoration: BoxDecoration(
            color: isSelected 
                ? color.withOpacity(0.1) 
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              if (isSelected)
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: Column(
            children: [
              Image.asset(emoji,width: 70,),
              SizedBox(height: 12.h),
              Text(
                title, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16.sp, 
                  color: isSelected ? color : (isDark ? Colors.white70 : Colors.black87)
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),

      appBar: AppBar(
        leading: CupertinoNavigationBarBackButton(
          color: context.isDark
              ? Colors.white
              : Colors.black,
        ),
        centerTitle: true,
        title: Text(
          "إعداد الحساب",

          style: TextStyle(
            fontFamily: "cairo",
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.h),
            Center(
              child: Image.asset("assets/images/halakat.png",width: 85,),
            ),
            SizedBox(height: 32.h),
            Text(
              'مرحباً بك في مجتمعات القرآن',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Text(
              'يرجى كتابة اسمك وتحديد جنسك لنعرض لك\nالمجتمعات المخصصة لك',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.5),
            ),
            SizedBox(height: 40.h),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'الاسم الأول',
                    icon: Icons.person_outline,
                    isDark: isDark,
                    maxLength: 15,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'الاسم الثاني',
                    icon: Icons.person_outline,
                    isDark: isDark,
                    maxLength: 15,
                  ),
                ),
              ],
            ),
            _buildTextField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              isDark: isDark,
            ),
            _buildTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              isDark: isDark,
            ),
            _buildTextField(
              controller: _locationController,
              label: 'الموقع/الدولة',
              icon: Icons.location_on_outlined,
              isOptional: true,
              isDark: isDark,
              suffixIcon: IconButton(
                icon: const Icon(Icons.public),
                color: KColors.primaryColor,
                tooltip: 'اختر من القائمة',
                onPressed: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: false,
                    countryListTheme: CountryListThemeData(
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      textStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontFamily: 'Cairo', fontSize: 16.sp),
                      searchTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontFamily: 'Cairo'),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
                    ),
                    onSelect: (Country country) {
                      _locationController.text = country.nameLocalized ?? country.name;
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                _buildGenderCard('male', 'رجل', 'assets/images/man.png', isDark),
                SizedBox(width: 16.w),
                _buildGenderCard('female', 'امرأة', 'assets/images/woman.png', isDark),
              ],
            ),
            SizedBox(height: 40.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: KColors.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    KColors.primaryColor.withOpacity(0.8),
                    KColors.primaryColor,
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('حفظ والمتابعة', style: TextStyle(fontSize: 18.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24.sp),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
