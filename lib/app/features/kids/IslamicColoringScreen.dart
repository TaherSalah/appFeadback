import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/style/k_dialog_helper.dart';
import 'kids_data/sounds_helper.dart';

class ColoringStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  ColoringStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });
}

class HadithTemplate {
  final String text;
  final String title;

  HadithTemplate({required this.text, required this.title});
}

class IslamicColoringScreen extends StatefulWidget {
  const IslamicColoringScreen({super.key});

  @override
  State<IslamicColoringScreen> createState() => _IslamicColoringScreenState();
}

class _IslamicColoringScreenState extends State<IslamicColoringScreen> {
  final List<HadithTemplate> _templates = [
    HadithTemplate(title: 'عن الأخلاق', text: 'البر حسن الخلق'),
    HadithTemplate(title: 'عن النظافة', text: 'الطهور شطر الإيمان'),
    HadithTemplate(title: 'عن الصدق', text: 'عليكم بالصدق'),
    HadithTemplate(title: 'عن الجنة', text: 'الجنة تحت أقدام الأمهات'),
  ];

  int _currentTemplateIndex = 0;
  List<ColoringStroke> _strokes = [];
  Color _selectedColor = Colors.red;
  double _brushSize = 35.0; // Increased default brush size
  int _stars = 0;
  double _coverage = 0.0;
  bool _isLevelComplete = false;
  
  // Points to check for coverage
  List<Offset> _targetPoints = [];
  Set<int> _hitPointIndices = {};

  final List<Color> _palette = [
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
    Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
    Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
    Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.brown, Colors.grey, Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _stars = prefs.getInt('coloring_stars') ?? 0;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coloring_stars', _stars);
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _hitPointIndices.clear();
      _coverage = 0.0;
      _isLevelComplete = false;
    });
  }

  void _nextTemplate() {
    setState(() {
      _currentTemplateIndex = (_currentTemplateIndex + 1) % _templates.length;
      _clearCanvas();
      _targetPoints.clear();
    });
  }

  void _updateCoverage(Offset point) {
    if (_targetPoints.isEmpty || _isLevelComplete) return;

    bool changed = false;
    // Slightly larger hit box for better feel
    final checkRadius = _brushSize * 0.8; 
    
    for (int i = 0; i < _targetPoints.length; i++) {
      if (!_hitPointIndices.contains(i)) {
        final dist = (point - _targetPoints[i]).distance;
        if (dist < checkRadius) {
          _hitPointIndices.add(i);
          changed = true;
        }
      }
    }

    if (changed) {
      setState(() {
        _coverage = _hitPointIndices.length / _targetPoints.length;
        if (_coverage >= 0.9 && !_isLevelComplete) {
          _completeLevel();
        }
      });
    }
  }

  void _completeLevel() {
    _isLevelComplete = true;
    _stars += 40;
    _saveProgress();
    KidsSoundHelper.playApplause();
    KidsSoundHelper.playTada();
    
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.success,
      icon: Icons.auto_awesome,
      title: 'رائع جداً! ✨',
      description: 'لقد لونت الحديث بشكل كامل وحصلت على 40 نجمة! ⭐',
      actions: [
        KDialogHelper.buildButton(
          context: context,
          label: 'الحديث التالي',
          color: Colors.green,
          onPressed: () {
            Navigator.pop(context);
            _nextTemplate();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final template = _templates[_currentTemplateIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[100],
        appBar: AppBar(
          leading: CupertinoNavigationBarBackButton(
            color: isDark ? Colors.white : Colors.black,
          ),
          title: Text(
            'لوّن الحديث الشريف',
            style: TextStyle(
                  fontFamily: "cairo",fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                   const Icon(Icons.star, color: Colors.amber, size: 20),
                   const SizedBox(width: 4),
                   Text('$_stars', style: TextStyle(
                  fontFamily: "cairo",fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book, color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          template.title,
                          style: TextStyle(
                  fontFamily: "cairo",fontWeight: FontWeight.bold, fontSize: 13.sp),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'تم التلوين: ${(_coverage * 100).toInt()}%',
                            style: TextStyle(
                  fontFamily: "cairo",color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11.sp),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _coverage,
                        backgroundColor: Colors.grey[200],
                        color: Colors.green,
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Canvas Area - Using Flexible and LayoutBuilder to avoid overflow
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: GestureDetector(
                      onPanStart: (details) {
                        if (_isLevelComplete) return;
                        setState(() {
                          _strokes.add(ColoringStroke(
                            points: [details.localPosition],
                            color: _selectedColor,
                            strokeWidth: _brushSize,
                          ));
                          _updateCoverage(details.localPosition);
                        });
                      },
                      onPanUpdate: (details) {
                        if (_isLevelComplete) return;
                        setState(() {
                          if (_strokes.isNotEmpty) {
                            _strokes.last.points.add(details.localPosition);
                            _updateCoverage(details.localPosition);
                          }
                        });
                      },
                      child: CustomPaint(
                        painter: ColoringPainter(
                          text: template.text,
                          strokes: _strokes,
                          onPointsGenerated: (points) {
                            if (_targetPoints.isEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) setState(() => _targetPoints = points);
                              });
                            }
                          },
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
  
              // Controls Section
              _buildControls(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clear and Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('اختر اللون وحجم الفرشاة:', style: TextStyle(
                  fontFamily: "cairo",fontSize: 11.sp, color: Colors.grey)),
              TextButton.icon(
                onPressed: _showClearConfirm,
                icon: const Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                label: Text('مسح', style: TextStyle(
                  fontFamily: "cairo",color: Colors.red, fontSize: 12.sp)),
              ),
            ],
          ),
          
          // Palette
          SizedBox(
            height: 45.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _palette.length,
              itemBuilder: (context, index) {
                final color = _palette[index];
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 40.r : 34.r,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 3),
                      boxShadow: [if (isSelected) BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Brush Size
          Row(
            children: [
              Icon(Icons.brush, size: 16, color: _selectedColor.withOpacity(0.6)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 12,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  ),
                  child: Slider(
                    value: _brushSize,
                    min: 20,
                    max: 80,
                    activeColor: _selectedColor,
                    onChanged: (val) => setState(() => _brushSize = val),
                  ),
                ),
              ),
              Icon(Icons.brush, size: 32, color: _selectedColor),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearConfirm() {
    KDialogHelper.showCustomDialog(
      context: context,
      type: KDialogType.warning,
      icon: Icons.warning_amber_rounded,
      title: 'مسح التلوين؟',
      description: 'هل تريد مسح كل الألوان والبدء من جديد؟',
      actions: [
        KDialogHelper.buildButton(context: context, label: 'إلغاء', isPrimary: false, onPressed: () => Navigator.pop(context)),
        KDialogHelper.buildButton(context: context, label: 'مسح الكل', color: Colors.red, onPressed: () {
            Navigator.pop(context);
            _clearCanvas();
        }),
      ],
    );
  }
}

class ColoringPainter extends CustomPainter {
  final String text;
  final List<ColoringStroke> strokes;
  final Function(List<Offset>)? onPointsGenerated;

  ColoringPainter({required this.text, required this.strokes, this.onPointsGenerated});

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // 1. Prepare Text Painter
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
                  fontFamily: "cairo",fontSize: size.width * 0.16, fontWeight: FontWeight.w900),
      ),
      textDirection: ui.TextDirection.rtl,
    )..layout(maxWidth: size.width - 40);

    final textOffset = Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2);

    // 2. Generate probe points for coverage if needed
    // Using a more dense grid for accuracy
    if (onPointsGenerated != null) {
      final List<Offset> points = [];
      final rect = textOffset & textPainter.size;
      for (double x = rect.left; x < rect.right; x += 10) { // More dense sampling
        for (double y = rect.top; y < rect.bottom; y += 10) {
          final offset = Offset(x, y);
          final pos = textPainter.getPositionForOffset(offset - textOffset);
          if (pos.offset >= 0 && pos.offset < text.length) {
             points.add(offset);
          }
        }
      }
      onPointsGenerated!(points);
    }

    // 3. Stencil Drawing
    final Rect canvasRect = Offset.zero & size;
    canvas.saveLayer(canvasRect, Paint());
    
    // Draw the text silhouette
    textPainter.paint(canvas, textOffset);

    // Draw the brush strokes over it using srcIn blend mode
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = BlendMode.srcIn;

    for (var stroke in strokes) {
      paint.color = stroke.color;
      paint.strokeWidth = stroke.strokeWidth;
      paint.style = PaintingStyle.stroke;

      if (stroke.points.length > 1) {
        final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      } else if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, stroke.strokeWidth / 2, paint..style = ui.PaintingStyle.fill);
      }
    }
    
    canvas.restore();

    // 4. Draw Outlines for clarity
    final outlinePainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
                  fontFamily: "cairo",
          fontSize: size.width * 0.16,
          fontWeight: FontWeight.w900,
          foreground: Paint()
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = Colors.grey.withOpacity(0.2),
        ),
      ),
      textDirection: ui.TextDirection.rtl,
    )..layout(maxWidth: size.width - 40);
    outlinePainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant ColoringPainter oldDelegate) => true;
}
