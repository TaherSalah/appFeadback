import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/achievement_models.dart';
import 'services/achievement_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final AchievementService _service = AchievementService();
  List<LeaderboardEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    await _service.init();
    setState(() => _entries = _service.getLeaderboard());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1F36) : const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: Text('لوحة الصدارة 🏆', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 20.sp)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: _entries.length,
          itemBuilder: (context, index) => _buildEntry(_entries[index], isDark),
        ),
      ),
    );
  }

  Widget _buildEntry(LeaderboardEntry entry, bool isDark) {
    final isUser = entry.name == 'أنت';
    final colors = [const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];
    final medal = entry.rank <= 3 ? ['🥇', '🥈', '🥉'][entry.rank - 1] : '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF8B5CF6).withOpacity(0.2) : (isDark ? const Color(0xFF2D3748) : Colors.white),
        borderRadius: BorderRadius.circular(16.r),
        border: isUser ? Border.all(color: const Color(0xFF8B5CF6), width: 2) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              gradient: entry.rank <= 3 ? LinearGradient(colors: [colors[entry.rank - 1], colors[entry.rank - 1].withOpacity(0.7)]) : null,
              color: entry.rank > 3 ? Colors.grey.shade300 : null,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(medal.isNotEmpty ? medal : '#${entry.rank}',
                style: GoogleFonts.cairo(fontSize: medal.isNotEmpty ? 20.sp : 16.sp, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 16.w),
          Text(entry.avatar, style: TextStyle(fontSize: 28.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Text('المستوى ${entry.level}', style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ),
          Text('${entry.points}', style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
        ],
      ),
    );
  }
}
