import 'package:flutter/material.dart';

class AppUpdateFeature {
  final String title;
  final IconData icon;

  AppUpdateFeature({
    required this.title,
    this.icon = Icons.auto_awesome_outlined,
  });
}

final List<AppUpdateFeature> recentUpdates = [
  AppUpdateFeature(
    title: 'إضافة ميزة التمرير التلقائي في صفحة القرآن الكريم، مما يتيح لك قراءة مريحة دون الحاجة للتنقل اليدوي بين الصفحات.',
    icon: Icons.auto_stories_outlined,
  ),
  AppUpdateFeature(
    title: 'إضافة القارئ الشيخ علي جابر رحمه الله إلى قائمة القراء.',
    icon: Icons.mic_none_outlined,
  ),
  AppUpdateFeature(
    title: 'تطوير نظام الأذان وجدولة التنبيهات لضمان العمل بدقة عالية في مواعيدها حتى في وضع السكون.',
    icon: Icons.notifications_active_outlined,
  ),
  AppUpdateFeature(
    title: 'إضافة نظام التذكيرات الذكية للورد القرآني وأذكار الصباح والمساء لضمان عدم نسيانها.',
    icon: Icons.psychology_outlined,
  ),
  AppUpdateFeature(
    title: 'تحسين نظام متابعة الختمات وإضافة تنبيهات يومية مخصصة لكل ختمة.',
    icon: Icons.menu_book_outlined,
  ),
  AppUpdateFeature(
    title: 'تحسينات شاملة في واجهة المستخدم وسرعة التنقل بين أقسام التطبيق المختلفة.',
    icon: Icons.speed_outlined,
  ),
];
