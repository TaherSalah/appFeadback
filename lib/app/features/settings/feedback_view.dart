import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import '../../core/services/feedback_service.dart';

/// شاشة إرسال الشكاوى والاقتراحات
class FeedbackView extends StatefulWidget {
  const FeedbackView({Key? key}) : super(key: key);

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _feedbackService = FeedbackService();
  final _imagePicker = ImagePicker();

  int _rating = 5;
  String _selectedCategory = 'مشكلة';
  List<File> _selectedImages = [];
  bool _isSubmitting = false;

  final List<String> _categories = [
    'مشكلة',
    'تحديث',
    'اقتراح',
    'استفسار',
    'أخرى',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((xFile) => File(xFile.path)).toList();
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _feedbackService.submitFeedback(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        rating: _rating,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
      );

      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
          // SnackBar(
          //   content: Text(
          //     'تم إرسال الملاحظات بنجاح ✅',
          //     style: GoogleFonts.cairo(),
          //   ),
          //   backgroundColor: Colors.green,
          //   behavior: SnackBarBehavior.floating,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          // ),
        // );
        KHelper.showSuccess(message:              'تم إرسال الملاحظات بنجاح ',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        KHelper.showError(message:               'فشل إرسال الملاحظات: $e',);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       'فشل إرسال الملاحظات: $e',
        //       style: GoogleFonts.cairo(),
        //     ),
        //     backgroundColor: Colors.red,
        //     behavior: SnackBarBehavior.floating,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //   ),
        // );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'الشكاوى والاقتراحات',
            style: GoogleFonts.cairo(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // مقدمة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.green.withOpacity(0.1)
                      : Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'نسعد بتلقي ملاحظاتكم واقتراحاتكم لتحسين التطبيق',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // حقل الاسم
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم *',
                  labelStyle: GoogleFonts.cairo(),
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                ),
                style: GoogleFonts.cairo(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال الاسم';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // حقل البريد الإلكتروني
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني *',
                  labelStyle: GoogleFonts.cairo(),
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                ),
                style: GoogleFonts.cairo(),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال البريد الإلكتروني';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'الرجاء إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // حقل رقم الهاتف (اختياري)
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف (اختياري)',
                  labelStyle: GoogleFonts.cairo(),
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                ),
                style: GoogleFonts.cairo(),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // اختيار التصنيف
              DropdownButtonFormField<String>(
                alignment: AlignmentGeometry.centerRight,
                value: _selectedCategory,
                decoration: InputDecoration(

                  labelText: 'التصنيف *',
                  labelStyle: GoogleFonts.cairo(),
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                ),
                style: GoogleFonts.cairo(
                  color: isDark ? Colors.white : Colors.black87,

                ),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: _categories.map((category) {
                  IconData icon;
                  Color color;

                  switch (category) {
                    case 'مشكلة':
                      icon = Icons.bug_report_outlined;
                      color = Colors.red;
                      break;
                    case 'تحديث':
                      icon = Icons.system_update_outlined;
                      color = Colors.blue;
                      break;
                    case 'اقتراح':
                      icon = Icons.lightbulb_outline;
                      color = Colors.amber;
                      break;
                    case 'استفسار':
                      icon = Icons.help_outline;
                      color = Colors.purple;
                      break;
                    default:
                      icon = Icons.more_horiz;
                      color = Colors.grey;
                  }

                  return DropdownMenuItem(
                    alignment: AlignmentGeometry.centerRight,
                    value: category,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(icon, color: color, size: 20),
                        const SizedBox(width: 12),
                        Text(category, style: GoogleFonts.cairo(),textAlign: TextAlign.right,),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
              const SizedBox(height: 24),

              // // تقييم النجوم
              // Center(
              //   child: Column(
              //     children: [
              //       Text(
              //         'ما هو تقييمك للتطبيق؟',
              //         style: GoogleFonts.cairo(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 16,
              //         ),
              //       ),
              //       const SizedBox(height: 8),
              //       Row(
              //         mainAxisSize: MainAxisSize.min,
              //         children: List.generate(5, (index) {
              //           return IconButton(
              //             onPressed: () {
              //               setState(() {
              //                 _rating = index + 1;
              //               });
              //             },
              //             icon: Icon(
              //               index < _rating ? Icons.star : Icons.star_border,
              //               color: Colors.amber,
              //               size: 32,
              //             ),
              //           );
              //         }),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 24),

              // حقل الوصف
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'الوصف *',
                  labelStyle: GoogleFonts.cairo(),
                  hintText: 'اكتب وصفاً تفصيلياً...',
                  hintStyle: GoogleFonts.cairo(color: Colors.grey),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                  alignLabelWithHint: true,
                ),
                style: GoogleFonts.cairo(),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال الوصف';
                  }
                  if (value.trim().length < 10) {
                    return 'الوصف قصير جداً (10 أحرف على الأقل)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // زر اختيار الصور
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _pickImages,
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  _selectedImages.isEmpty
                      ? 'إضافة صور (اختياري)'
                      : 'تم اختيار ${_selectedImages.length} صورة',
                  style: GoogleFonts.cairo(),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: _selectedImages.isEmpty
                        ? (isDark ? Colors.white30 : Colors.grey)
                        : Colors.green,
                  ),
                ),
              ),

              // عرض الصور المختارة
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              left: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // زر الإرسال
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'إرسال',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // ملاحظة الخصوصية
              Text(
                'ملاحظة: سيتم جمع معلومات الجهاز تلقائياً (نظام التشغيل، الإصدار، الموديل) للمساعدة في حل المشاكل التقنية.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
