import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';

import '../../core/utils/style/k_dialog_helper.dart';
import 'kids_data/sounds_helper.dart';

class InteractiveWuduScreen extends StatefulWidget {
  const InteractiveWuduScreen({super.key});

  @override
  State<InteractiveWuduScreen> createState() => _InteractiveWuduScreenState();
}

class _InteractiveWuduScreenState extends State<InteractiveWuduScreen> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _wuduSteps = [
    {
      'title': 'النية',
      'description': 'أنوي أن أتوضأ لله تعالى',
      'emoji': '💭',
      'detail': 'النية في القلب، لا تحتاج للنطق بها',
    },
    {
      'title': 'البسملة',
      'description': 'قل: بسم الله الرحمن الرحيم',
      'emoji': '🤲',
      'detail': 'ابدأ بذكر اسم الله',
    },
    {
      'title': 'غسل الكفين',
      'description': 'اغسل يديك 3 مرات',
      'emoji': '🙌',
      'detail': 'افرك يديك جيداً بالماء والصابون',
    },
    {
      'title': 'المضمضة والاستنشاق',
      'description': 'تمضمض واستنشق 3 مرات',
      'emoji': '👃',
      'detail': 'ضع الماء في فمك وأنفك ثم أخرجه',
    },
    {
      'title': 'غسل الوجه',
      'description': 'اغسل وجهك 3 مرات',
      'emoji': '😊',
      'detail': 'من الجبهة إلى الذقن، ومن الأذن إلى الأذن',
    },
    {
      'title': 'غسل اليدين',
      'description': 'اغسل يديك إلى المرفقين 3 مرات',
      'emoji': '💪',
      'detail': 'ابدأ باليد اليمنى ثم اليسرى',
    },
    {
      'title': 'مسح الرأس',
      'description': 'امسح رأسك مرة واحدة',
      'emoji': '👨',
      'detail': 'من الأمام إلى الخلف بالماء',
    },
    {
      'title': 'مسح الأذنين',
      'description': 'امসح أذنيك مرة واحدة',
      'emoji': '👂',
      'detail': 'من الداخل والخارج',
    },
    {
      'title': 'غسل القدمين',
      'description': 'اغسل قدميك إلى الكعبين 3 مرات',
      'emoji': '🦶',
      'detail': 'ابدأ بالقدم اليمنى ثم اليسرى',
    },
  ];

  void _nextStep() {
    if (_currentStep < _wuduSteps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _showCompletionDialog();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showCompletionDialog() {
    KidsSoundHelper.playApplause();
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.water_drop_rounded,
      title: 'أحسنت يا بطل! 🎉',
      description: 'لقد تعلمت خطوات الوضوء الصحيحة بنجاح وتستحق هذه المكافأة!',
      additionalContent: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 28),
            const SizedBox(width: 10),
            Text(
              'لقد حصلت على 50 نجمة ✨',
              style: TextStyle(
                  fontFamily: "cairo",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: 'إعادة',
          isPrimary: false,
          onPressed: () {
            Navigator.pop(context);
            setState(() => _currentStep = 0);
          },
        ),
        KDialogHelper.buildButton(
          context: context,
          label: 'تمام',
          color: const Color(0xFF10B981),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final step = _wuduSteps[_currentStep];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'تعليم الوضوء 💧',
            style: TextStyle(
                  fontFamily: "cairo",
              fontWeight: FontWeight.bold,
              fontSize: context.isTab ? 14.sp : 20.sp,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Progress bar
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الخطوة ${_currentStep + 1} من ${_wuduSteps.length}',
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize:
                              context.isTab ? 10.sp : 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${((_currentStep + 1) / _wuduSteps.length * 100).toInt()}%',
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize:
                              context.isTab ? 10.sp : 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00BCD4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _wuduSteps.length,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF00BCD4)),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Emoji
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BCD4).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          step['emoji'],
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      step['title'],
                      style: TextStyle(
                  fontFamily: "cairo",
                        fontSize:
                            context.isTab ? 16.sp : 24.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BCD4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00BCD4).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        step['description'],
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontSize:
                              context.isTab ? 12.sp : 18.sp,
                          height: 1.8,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Detail
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step['detail'],
                              style: TextStyle(
                  fontFamily: "cairo",
                                fontSize: context.isTab
                                    ? 10.sp
                                    : 14.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _previousStep,
                        icon: const Icon(Icons.arrow_back),
                        label: Text('السابق', style: TextStyle(
                  fontFamily: "cairo",)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _nextStep,
                      icon: Icon(
                        _currentStep == _wuduSteps.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      label: Text(
                        _currentStep == _wuduSteps.length - 1
                            ? 'إنهاء'
                            : 'التالي',
                        style: TextStyle(
                  fontFamily: "cairo",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
