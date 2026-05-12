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
    title: 'إضافة معلومات إضافية في المواريث',
    icon: Icons.account_balance_outlined,
  ),
  AppUpdateFeature(
    title: 'إضافة مسبحة إلكترونية',
    icon: Icons.fingerprint_outlined,
  ),
  AppUpdateFeature(
    title: 'تعديلات في المصحف وتحسينات',
    icon: Icons.menu_book_outlined,
  ),
  AppUpdateFeature(
    title: 'التعديل في نظام الإشعارات',
    icon: Icons.notifications_active_outlined,
  ),
  AppUpdateFeature(
    title: 'إضافة خيارات متقدمة للوضع الليلي الصامت، للتحكم في الإشعارات خلال أوقات الراحة.',
    icon: Icons.nights_stay_outlined,
  ),
];
