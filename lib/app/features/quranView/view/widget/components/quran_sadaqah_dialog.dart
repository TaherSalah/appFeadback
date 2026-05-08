import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// يعرض dialog "مشاركة كصدقة جارية" ويعيد الاسم المختار عبر [onShare]
Future<void> showSadaqahDialog({
  required BuildContext context,
  required bool isDark,
  required void Function(String? name) onShare,
}) async {
  String selectedName = "";
  final names = ["والديّ", "جميع المسلمين", "والدي ووالدتي", "نفسي"];

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setModalState) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ─── جسم الديالوج ───
              Container(
                padding: const EdgeInsets.fromLTRB(20, 45, 20, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: isDark
                        ? [
                            const Color(0xFF0B1A14),
                            const Color(0xFF070B14)
                          ]
                        : [
                            const Color(0xFFE0F2F1),
                            const Color(0xFFB2DFDB)
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'مشاركة كصدقة جارية',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : Colors.teal.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اكتب اسم الشخص الذي تود إهداء ثواب القراءة له، أو اختر من الخيارات السريعة.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.4,
                        color: isDark
                            ? Colors.white70
                            : Colors.teal.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    // ─── حقل الاسم ───
                    TextField(
                      onChanged: (v) => selectedName = v,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "اكتب الاسم هنا...",
                        hintStyle: TextStyle(
                            color:
                                isDark ? Colors.grey : Colors.grey[600]),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white12
                            : Colors.white.withOpacity(0.5),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // ─── خيارات سريعة ───
                    Wrap(
                      spacing: 8,
                      children: names
                          .map((n) => ChoiceChip(
                                label: Text(
                                  n,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: selectedName == n
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white70
                                            : Colors.teal.shade900),
                                  ),
                                ),
                                selected: selectedName == n,
                                onSelected: (_) {
                                  setModalState(
                                      () => selectedName = n);
                                },
                                selectedColor: Colors.teal,
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.teal.shade50,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 24.h),
                    // ─── أزرار ───
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.teal.shade300,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 11),
                            ),
                            child: Text(
                              'تراجع',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: isDark
                                    ? Colors.white
                                    : Colors.teal.shade900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              onShare(selectedName.trim().isEmpty
                                  ? null
                                  : selectedName);
                            },
                            icon: const Icon(Icons.share_rounded,
                                size: 18),
                            label: const Text('مشاركة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ─── أيقونة دائرية أعلى الديالوج ───
              Positioned(
                top: -35,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.tealAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.volunteer_activism_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
