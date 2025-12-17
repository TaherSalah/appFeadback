import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/style/responsive_util.dart';

class VirtualPetWidget extends StatefulWidget {
  final int totalStars;

  const VirtualPetWidget({super.key, required this.totalStars});

  @override
  State<VirtualPetWidget> createState() => _VirtualPetWidgetState();
}

class _VirtualPetWidgetState extends State<VirtualPetWidget> {
  String _petName = 'صديقي';
  int _petLevel = 1;
  String _petType = 'cat';

  @override
  void initState() {
    super.initState();
    _loadPet();
  }

  Future<void> _loadPet() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _petName = prefs.getString('pet_name') ?? 'صديقي';
      _petType = prefs.getString('pet_type') ?? 'cat';
      _petLevel = _calculateLevel(widget.totalStars);
    });
  }

  int _calculateLevel(int stars) {
    if (stars < 100) return 1; // بيضة
    if (stars < 300) return 2; // صغير
    if (stars < 600) return 3; // متوسط
    if (stars < 1000) return 4; // كبير
    return 5; // بطل
  }

  String _getPetEmoji() {
    if (_petType == 'lion') {
      if (_petLevel == 1) return '🥚';
      if (_petLevel == 2) return '🦁';
      if (_petLevel == 3) return '🦁';
      if (_petLevel == 4) return '🦁';
      return '👑🦁';
    } else if (_petType == 'bird') {
      if (_petLevel == 1) return '🥚';
      if (_petLevel == 2) return '🐣';
      if (_petLevel == 3) return '🐥';
      if (_petLevel == 4) return '🦅';
      return '👑🦅';
    } else {
      // cat (default)
      if (_petLevel == 1) return '🥚';
      if (_petLevel == 2) return '🐱';
      if (_petLevel == 3) return '😺';
      if (_petLevel == 4) return '😸';
      return '👑🐱';
    }
  }

  String _getLevelName() {
    switch (_petLevel) {
      case 1:
        return 'بيضة';
      case 2:
        return 'صغير';
      case 3:
        return 'متوسط';
      case 4:
        return 'كبير';
      case 5:
        return 'بطل';
      default:
        return 'مستكشف';
    }
  }

  String _getMotivationMessage() {
    if (_petLevel == 1) return 'اجمع 100 نجمة لأفقس! 🥚';
    if (_petLevel == 2) return 'اجمع 300 نجمة لأكبر! 🌱';
    if (_petLevel == 3) return 'اجمع 600 نجمة لأصير أقوى! 💪';
    if (_petLevel == 4) return 'اجمع 1000 نجمة لأصبح بطلاً! 🏆';
    return 'أنت أفضل صديق! 🌟';
  }

  void _showPetInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(_getPetEmoji(), style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 8),
            Text(
              _petName,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المستوى: ${_getLevelName()}',
              style: GoogleFonts.cairo(fontSize: 16.sp),
            ),
            const SizedBox(height: 8),
            Text(
              'النجوم: ${widget.totalStars}',
              style: GoogleFonts.cairo(fontSize: 14.sp),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getMotivationMessage(),
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق', style: GoogleFonts.cairo()),
          ),
          if (_petLevel < 5)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Could navigate to games or challenges
              },
              child: Text('اجمع نجوم!', style: GoogleFonts.cairo()),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPetInfo,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade300,
              Colors.pink.shade300,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getPetEmoji(),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _petName,
                    style: GoogleFonts.cairo(
                      fontSize:
                          ResponsiveUtil.isTablet(context) ? 12.sp : 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'المستوى: ${_getLevelName()}',
                    style: GoogleFonts.cairo(
                      fontSize:
                          ResponsiveUtil.isTablet(context) ? 10.sp : 14.sp,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: _petLevel / 5,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.amber),
                  ),
                ],
              ),
            ),
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
