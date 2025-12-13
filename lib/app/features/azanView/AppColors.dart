// import 'package:flutter/material.dart';
//
// /// 🎨 نظام الألوان الموحد للتطبيق
// class AppColors {
//   AppColors._();
//
//   // ========== الألوان الأساسية ==========
//   static const Color primary = Color(0xFF4CAF50); // أخضر
//   static const Color secondary = Color(0xFF2196F3); // أزرق
//   static const Color accent = Color(0xFFFF9800); // برتقالي
//   static const Color error = Color(0xFFE53935); // أحمر
//   static const Color success = Color(0xFF43A047); // أخضر نجاح
//   static const Color warning = Color(0xFFFFA726); // برتقالي تحذير
//   static const Color info = Color(0xFF29B6F6); // أزرق معلومات
//
//   // ========== الوضع النهاري (Light Mode) ==========
//   static class Light {
//   // الخلفيات
//   static const Color background = Color(0xFFF5F7FA);
//   static const Color surface = Color(0xFFFFFFFF);
//   static const Color cardBackground = Color(0xFFFFFFFF);
//   static const Color dialogBackground = Color(0xFFFFFFFF);
//
//   // النصوص
//   static const Color textPrimary = Color(0xFF1A1A1A);
//   static const Color textSecondary = Color(0xFF666666);
//   static const Color textHint = Color(0xFF999999);
//   static const Color textDisabled = Color(0xFFBDBDBD);
//
//   // الحدود والفواصل
//   static const Color border = Color(0xFFE0E0E0);
//   static const Color divider = Color(0xFFEEEEEE);
//
//   // الأزرار
//   static const Color buttonPrimary = Color(0xFF4CAF50);
//   static const Color buttonSecondary = Color(0xFF2196F3);
//   static const Color buttonDisabled = Color(0xFFE0E0E0);
//   static const Color buttonText = Color(0xFFFFFFFF);
//
//   // الحقول
//   static const Color inputBackground = Color(0xFFF5F5F5);
//   static const Color inputBorder = Color(0xFFE0E0E0);
//   static const Color inputFocusedBorder = Color(0xFF4CAF50);
//   static const Color inputErrorBorder = Color(0xFFE53935);
//
//   // الظلال
//   static Color shadow = Colors.black.withOpacity(0.08);
//   static Color shadowLight = Colors.black.withOpacity(0.04);
//
//   // التدرجات اللونية
//   static const List<Color> gradientPrimary = [
//   Color(0xFF4CAF50),
//   Color(0xFF66BB6A),
//   ];
//
//   static const List<Color> gradientSecondary = [
//   Color(0xFF2196F3),
//   Color(0xFF42A5F5),
//   ];
//
//   static const List<Color> gradientCard = [
//   Color(0xFFFFFFFF),
//   Color(0xFFF5F7FA),
//   ];
//
//   // الأيقونات
//   static const Color iconPrimary = Color(0xFF1A1A1A);
//   static const Color iconSecondary = Color(0xFF666666);
//   static const Color iconDisabled = Color(0xFFBDBDBD);
//
//   // حالات خاصة
//   static const Color selectedItem = Color(0xFFE8F5E9);
//   static const Color hoverItem = Color(0xFFF5F5F5);
//   static const Color activeItem = Color(0xFF4CAF50);
//   }
//
//   // ========== الوضع الليلي (Dark Mode) ==========
//   static class Dark {
//   // الخلفيات
//   static const Color background = Color(0xFF0F172A);
//   static const Color surface = Color(0xFF1E293B);
//   static const Color cardBackground = Color(0xFF1E293B);
//   static const Color dialogBackground = Color(0xFF1E293B);
//
//   // النصوص
//   static const Color textPrimary = Color(0xFFFFFFFF);
//   static const Color textSecondary = Color(0xFFB0B0B0);
//   static const Color textHint = Color(0xFF666666);
//   static const Color textDisabled = Color(0xFF404040);
//
//   // الحدود والفواصل
//   static const Color border = Color(0xFF334155);
//   static const Color divider = Color(0xFF2D3748);
//
//   // الأزرار
//   static const Color buttonPrimary = Color(0xFF4CAF50);
//   static const Color buttonSecondary = Color(0xFF2196F3);
//   static const Color buttonDisabled = Color(0xFF334155);
//   static const Color buttonText = Color(0xFFFFFFFF);
//
//   // الحقول
//   static const Color inputBackground = Color(0xFF334155);
//   static const Color inputBorder = Color(0xFF475569);
//   static const Color inputFocusedBorder = Color(0xFF4CAF50);
//   static const Color inputErrorBorder = Color(0xFFE53935);
//
//   // الظلال
//   static Color shadow = Colors.black.withOpacity(0.4);
//   static Color shadowLight = Colors.black.withOpacity(0.2);
//
//   // التدرجات اللونية
//   static const List<Color> gradientPrimary = [
//   Color(0xFF4CAF50),
//   Color(0xFF388E3C),
//   ];
//
//   static const List<Color> gradientSecondary = [
//   Color(0xFF2196F3),
//   Color(0xFF1976D2),
//   ];
//
//   static const List<Color> gradientCard = [
//   Color(0xFF1E293B),
//   Color(0xFF334155),
//   ];
//
//   // الأيقونات
//   static const Color iconPrimary = Color(0xFFFFFFFF);
//   static const Color iconSecondary = Color(0xFFB0B0B0);
//   static const Color iconDisabled = Color(0xFF404040);
//
//   // حالات خاصة
//   static const Color selectedItem = Color(0xFF2D3748);
//   static const Color hoverItem = Color(0xFF334155);
//   static const Color activeItem = Color(0xFF4CAF50);
//   }
// }
//
// /// 🎨 Helper للحصول على الألوان حسب الوضع
// class AppTheme {
//   AppTheme._();
//
//   /// التحقق من الوضع الليلي
//   static bool isDarkMode(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark;
//   }
//
//   // ========== الخلفيات ==========
//   static Color background(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.background : AppColors.Light.background;
//
//   static Color surface(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.surface : AppColors.Light.surface;
//
//   static Color cardBackground(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.cardBackground : AppColors.Light.cardBackground;
//
//   static Color dialogBackground(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.dialogBackground : AppColors.Light.dialogBackground;
//
//   // ========== النصوص ==========
//   static Color textPrimary(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.textPrimary : AppColors.Light.textPrimary;
//
//   static Color textSecondary(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.textSecondary : AppColors.Light.textSecondary;
//
//   static Color textHint(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.textHint : AppColors.Light.textHint;
//
//   static Color textDisabled(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.textDisabled : AppColors.Light.textDisabled;
//
//   // ========== الحدود والفواصل ==========
//   static Color border(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.border : AppColors.Light.border;
//
//   static Color divider(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.divider : AppColors.Light.divider;
//
//   // ========== الأزرار ==========
//   static Color buttonPrimary(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.buttonPrimary : AppColors.Light.buttonPrimary;
//
//   static Color buttonSecondary(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.buttonSecondary : AppColors.Light.buttonSecondary;
//
//   static Color buttonDisabled(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.buttonDisabled : AppColors.Light.buttonDisabled;
//
//   static Color buttonText(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.buttonText : AppColors.Light.buttonText;
//
//   // ========== الحقول ==========
//   static Color inputBackground(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.inputBackground : AppColors.Light.inputBackground;
//
//   static Color inputBorder(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.inputBorder : AppColors.Light.inputBorder;
//
//   static Color inputFocusedBorder(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.inputFocusedBorder : AppColors.Light.inputFocusedBorder;
//
//   static Color inputErrorBorder(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.inputErrorBorder : AppColors.Light.inputErrorBorder;
//
//   // ========== الظلال ==========
//   static Color shadow(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.shadow : AppColors.Light.shadow;
//
//   static Color shadowLight(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.shadowLight : AppColors.Light.shadowLight;
//
//   // ========== التدرجات ==========
//   static List<Color> gradientPrimary(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.gradientPrimary : AppColors.Light.gradientPrimary;
//
//   static List<Color> gradientSecondary(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.gradientSecondary : AppColors.Light.gradientSecondary;
//
//   static List<Color> gradientCard(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.gradientCard : AppColors.Light.gradientCard;
//
//   // ========== الأيقونات ==========
//   static Color iconPrimary(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.iconPrimary : AppColors.Light.iconPrimary;
//
//   static Color iconSecondary(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.iconSecondary : AppColors.Light.iconSecondary;
//
//   static Color iconDisabled(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.iconDisabled : AppColors.Light.iconDisabled;
//
//   // ========== حالات خاصة ==========
//   static Color selectedItem(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.selectedItem : AppColors.Light.selectedItem;
//
//   static Color hoverItem(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.hoverItem : AppColors.Light.hoverItem;
//
//   static Color activeItem(BuildContext context) =>
//       isDarkMode(context) ? AppColors.Dark.activeItem : AppColors.Light.activeItem;
//
//   // ========== BoxShadow جاهزة ==========
//   static List<BoxShadow> cardShadow(BuildContext context) => [
//     BoxShadow(
//       color: shadow(context),
//       blurRadius: 10,
//       offset: const Offset(0, 4),
//     ),
//   ];
//
//   static List<BoxShadow> buttonShadow(BuildContext context) => [
//     BoxShadow(
//       color: shadow(context),
//       blurRadius: 8,
//       offset: const Offset(0, 3),
//     ),
//   ];
//
//   static List<BoxShadow> elevatedShadow(BuildContext context) => [
//     BoxShadow(
//       color: shadow(context),
//       blurRadius: 15,
//       offset: const Offset(0, 5),
//     ),
//   ];
// }
//
// /// 🎨 ألوان خاصة بمواقيت الصلاة
// class PrayerTimesColors {
//   PrayerTimesColors._();
//
//   // الصلاة القادمة - النهاري
//   static const List<Color> nextPrayerGradientLight = [
//     Color(0xFF4CAF50),
//     Color(0xFF00897B),
//   ];
//
//   // الصلاة القادمة - الليلي
//   static const List<Color> nextPrayerGradientDark = [
//     Color(0xFFFFA726),
//     Color(0xFFFF6F00),
//   ];
//
//   // بطاقة الموقع - النهاري
//   static const List<Color> locationGradientLight = [
//     Color(0xFF64B5F6),
//     Color(0xFFBA68C8),
//   ];
//
//   // بطاقة الموقع - الليلي
//   static const List<Color> locationGradientDark = [
//     Color(0xFF5C6BC0),
//     Color(0xFF7E57C2),
//   ];
//
//   // أيقونات الصلوات
//   static const Color fajrIcon = Color(0xFF5E35B1);
//   static const Color sunriseIcon = Color(0xFFFFB300);
//   static const Color dhuhrIcon = Color(0xFFFF6F00);
//   static const Color asrIcon = Color(0xFFF57C00);
//   static const Color maghribIcon = Color(0xFFD84315);
//   static const Color ishaIcon = Color(0xFF1565C0);
//
//   static List<Color> nextPrayerGradient(BuildContext context) =>
//       AppTheme.isDarkMode(context) ? nextPrayerGradientDark : nextPrayerGradientLight;
//
//   static List<Color> locationGradient(BuildContext context) =>
//       AppTheme.isDarkMode(context) ? locationGradientDark : locationGradientLight;
// }
//
// /// 📝 مثال على الاستخدام:
// ///
// /// ```dart
// /// // في أي Widget:
// /// Container(
// ///   color: AppTheme.cardBackground(context),
// ///   child: Text(
// ///     'مرحباً',
// ///     style: TextStyle(color: AppTheme.textPrimary(context)),
// ///   ),
// /// )
// ///
// /// // استخدام التدرجات:
// /// Container(
// ///   decoration: BoxDecoration(
// ///     gradient: LinearGradient(
// ///       colors: AppTheme.gradientPrimary(context),
// ///     ),
// ///   ),
// /// )
// ///
// /// // استخدام الظلال:
// /// Container(
// ///   decoration: BoxDecoration(
// ///     boxShadow: AppTheme.cardShadow(context),
// ///   ),
// /// )
// /// ```a