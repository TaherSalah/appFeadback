import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/app_theme_colors.dart';
import 'package:muslimdaily/app/core/utils/style/k_color.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:muslimdaily/app/core/utils/style/responsive_util.dart';
import 'package:muslimdaily/app/core/widgets/KLoading.dart';
import 'package:muslimdaily/app/features/Khatmah/data/global_khatmah_service.dart';
import 'package:muslimdaily/app/features/quran/SurahModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:muslimdaily/app/core/services/notification_manager.dart';
import 'package:muslimdaily/app/features/Khatmah/view/khatmah_certificate_screen.dart';
import 'package:muslimdaily/app/features/quran/quranView.dart';
import 'package:quran/quran.dart' as quran;

class GlobalKhatmahScreen extends StatefulWidget {
  const GlobalKhatmahScreen({super.key});

  @override
  State<GlobalKhatmahScreen> createState() => _GlobalKhatmahScreenState();
}

enum _KhatmahMenuAction { analytics, share, help }

class _GlobalKhatmahScreenState extends State<GlobalKhatmahScreen> {
  final GlobalKhatmahService _service = GlobalKhatmahService();
  List<Map<String, dynamic>> _campaigns = [];
  int _selectedCampaignIndex = 0;
  bool _isDetailView = false;
  List<Map<String, dynamic>> _progress = [];
  List<Map<String, dynamic>> _globalLeaderboard = [];
  List<Map<String, dynamic>> _recentGlobalActivity = [];
  Map<String, dynamic> _userStats = {
    'total_completed': 0,
    'community_percent': '0',
    'history': []
  };
  List<SurahModel> _surahs = [];
  bool _isLoading = true;
  RealtimeChannel? _subscription;
  Set<int> _myClaims = {}; // Track user's own claims locally
  String? _userNickname;
  late ConfettiController _confettiController;
  Map<String, dynamic> _communityGlobalStats = {
    'total_completed': 0,
    'active_readers': 0,
    'today_completions': 0
  };
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _quotes = [
    "«خَيْرُكُمْ مَنْ تَعَلَّمَ القُرْآنَ وَعَلَّمَهُ»",
    "«الَّذِي يَقْرَأُ القُرْآنَ وَهُوَ مَاهِرٌ بِهِ مَعَ السَّفَرَةِ الكِرَامِ البَرَرَةِ»",
    "«اقْرَؤُوا القُرْآنَ فَإِنَّهُ يَأْتِي يَوْمَ القِيَامَةِ شَفِيعًا لِأَصْحَابِهِ»",
    "«يُقَالُ لِصَاحِبِ الْقُرْآنِ: اقْرَأْ، وَارْتَقِ، وَرَتِّلْ كَمَا كُنْتَ تُرَتِّلُ فِي الدُّنْيَا»",
    "«مَنْ قَرَأَ حَرْفًا مِنْ كِتَابِ اللَّهِ فَلَهُ بِهِ حَسَنَةٌ، وَالحَسَنَةُ بِعَشْرِ أَمْثَالِهَا»",
  ];
  late String _currentQuote;
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _currentQuote = _quotes[math.Random().nextInt(_quotes.length)];
    _loadData();

    // Show help dialog on first visit
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenHelp = prefs.getBool('global_khatmah_help_seen') ?? false;
      if (!hasSeenHelp && mounted) {
        _showHelpDialog();
        await prefs.setBool('global_khatmah_help_seen', true);
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // 1. Load Campaigns
    _campaigns = await _service.getActiveCampaigns();

    // 2. Load Global Stats & Activity
    final prefs = await SharedPreferences.getInstance();
    _userNickname = prefs.getString('user_khatmah_nickname');

    if (_userNickname != null) {
      _userStats = await _service.getUserKhatmahStats(_userNickname!);
    }

    _globalLeaderboard = await _service.getGlobalLeaderboard();
    _recentGlobalActivity = await _service.getRecentGlobalActivity();
    _communityGlobalStats = await _service.getCommunityGlobalStats();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Refresh user statistics after completing parts
  Future<void> _refreshUserStats() async {
    if (_userNickname == null || _userNickname!.isEmpty) return;

    try {
      final updatedStats = await _service.getUserKhatmahStats(_userNickname!);
      if (mounted) {
        setState(() {
          _userStats = updatedStats;
        });
      }
    } catch (e) {
      print('Error refreshing user stats: $e');
    }
  }

  Future<void> _switchCampaign(int index) async {
    if (index >= _campaigns.length) return;

    // Unsubscribe from previous
    _subscription?.unsubscribe();

    final campaign = _campaigns[index];
    final campaignId = campaign['id'];

    // Clear old state
    setState(() {
      _selectedCampaignIndex = index;
      _progress = [];
    });

    // Load new progress
    _progress = await _service.getCampaignProgress(campaignId);

    // Load Surahs for all campaigns to enable Quran navigation
    _surahs = await loadQuranFromAssets();

    // Run Smart Auto-Release cleanup
    await _service.autoReleaseExpiredClaims(campaignId);

    // Load my claims from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedClaims =
        prefs.getStringList('my_global_claims_$campaignId') ?? [];
    _myClaims = savedClaims.map((e) => int.parse(e)).toSet();

    // Subscribe to new real-time updates
    _subscription = _service.subscribeToProgress(campaignId, (payload) {
      if (mounted) {
        _handleRealtimeUpdate(payload);
      }
    });

    if (mounted) {
      setState(() {
        _isDetailView = true;
      });
    }
  }

  void _backToDashboard() {
    _subscription?.unsubscribe();
    setState(() {
      _isDetailView = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  final RegExp nicknameRegex = RegExp(r'^[a-zA-Z\u0600-\u06FF ]+$');
  String? validateNickname(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return 'الاسم لا يمكن أن يكون فارغًا';
    }

    if (trimmed.length < 3) {
      return 'الاسم قصير جدًا';
    }

    if (trimmed.length > 12) {
      return 'الاسم طويل جدًا';
    }

    if (!nicknameRegex.hasMatch(trimmed)) {
      return 'يُسمح بالحروف فقط بدون أرقام أو رموز';
    }

    return null; // الاسم صحيح ✅
  }

  Future<void> _ensureNickname() async {
    if (_userNickname != null && _userNickname!.isNotEmpty) return;

    final controller = TextEditingController();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const int maxLength = 12;
    final errorText = validateNickname(controller.text);
    final isValid = errorText == null;
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: StatefulBuilder(
                builder: (context, setLocalState) {
                  final errorMessage = validateNickname(controller.text);
                  final isValid = errorMessage == null;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: isDark
                                ? [
                                    const Color(0xFF0F2A24),
                                    const Color(0xFF081C18),
                                  ]
                                : [
                                    const Color(0xFFEFFFFA),
                                    const Color(0xFFDFF5EE),
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'أدخل اسمك للمنافسة',
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'سيظهر هذا الاسم للمشاركين الآخرين',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 13.5,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Input
                            TextField(
                              controller: controller,
                              maxLength: maxLength,
                              textAlign: TextAlign.center,
                              onChanged: (_) => setLocalState(() {}),
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: 'مثلاً: فاعل خير',
                                filled: true,
                                fillColor:
                                    isDark ? Colors.black26 : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                errorStyle: GoogleFonts.cairo(fontSize: 11),
                              ),
                            ),

                            if (errorMessage != null &&
                                controller.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  errorMessage,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 18),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      'إلغاء',
                                      style: GoogleFonts.cairo(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: isValid
                                        ? () async {
                                            final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            await prefs.setString(
                                              'user_khatmah_nickname',
                                              controller.text.trim(),
                                            );
                                            setState(() {
                                              _userNickname =
                                                  controller.text.trim();
                                            });
                                            Navigator.pop(context);
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      'حفظ',
                                      style: GoogleFonts.cairo(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Icon
                      Positioned(
                        top: -30,
                        left: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.teal,
                          child: const Icon(
                            Icons.person_outline,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  void _handleRealtimeUpdate(PostgresChangePayload payload) {
    if (!mounted) return;

    final newRecord = payload.newRecord;
    if (newRecord.isEmpty) return;

    final index = newRecord['item_index'] as int?;
    if (index == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          final existingIndex =
              _progress.indexWhere((p) => p['item_index'] == index);
          if (existingIndex != -1) {
            _progress[existingIndex] = Map<String, dynamic>.from(newRecord);
          } else {
            _progress.add(Map<String, dynamic>.from(newRecord));
          }

          if (_completionPercent >= 1.0) {
            _confettiController.play();
          }
        });
      }
    });
  }

  double get _completionPercent {
    if (_campaigns.isEmpty) return 0;
    final campaign = _campaigns[_selectedCampaignIndex];
    final total = campaign['target_total'] ?? 0;
    if (total == 0) return 0;
    final completed =
        _progress.where((p) => (p['status'] ?? '') == 'completed').length;
    return (completed / total).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.green),
          onPressed: _isDetailView
              ? _backToDashboard
              : () => Navigator.pop(context),
        ),
        title: Text(
          _isDetailView ? 'تفاصيل الختمة' : 'الختمة الجماعية',
          style: GoogleFonts.cairo(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<_KhatmahMenuAction>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.green),
            offset: const Offset(0, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            onSelected: (value) {
              switch (value) {
                case _KhatmahMenuAction.analytics:
                  _showPersonalAnalytics();
                  break;
                case _KhatmahMenuAction.share:
                  _shareProgress();
                  break;
                case _KhatmahMenuAction.help:
                  _showHelpDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              _buildKhatmahMenuItem(
                value: _KhatmahMenuAction.analytics,
                title: 'إحصائياتي',
                subtitle: 'تحليل أدائك ومساهمتك',
                icon: Icons.analytics_outlined,
                iconColor: Colors.blue,
                isDark: isDark,
              ),
              _buildKhatmahMenuItem(
                value: _KhatmahMenuAction.share,
                title: 'نشر التقدم',
                subtitle: 'شارك إنجازك مع الآخرين',
                icon: Icons.share_rounded,
                iconColor: Colors.green,
                isDark: isDark,
              ),
              _buildKhatmahMenuItem(
                value: _KhatmahMenuAction.help,
                title: 'دليل المشاركة',
                subtitle: 'كيفية استخدام الخدمة',
                icon: Icons.help_outline_rounded,
                iconColor: Colors.amber,
                isDark: isDark,
              ),
            ],
          ),
        ],

        // flexibleSpace: Container(
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //       colors: [KColors.primaryColor, KColors.primaryColor.withOpacity(0.7)],
        //     ),
        //   ),
        // ),
      ),

      body: _isLoading
          ? Center(
              child:  KLoading.progressIOSIndicator(context: context))
          : _campaigns.isEmpty
              ? _buildNoCampaign()
              : _isDetailView
                  ? Stack(
                      children: [
                        _buildMainContent(isDark),
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConfettiWidget(
                            confettiController: _confettiController,
                            blastDirectionality: BlastDirectionality.explosive,
                            shouldLoop: false,
                            colors: const [
                              Colors.green,
                              Colors.blue,
                              Colors.pink,
                              Colors.orange,
                              Colors.purple
                            ],
                            createParticlePath: _drawStar,
                          ),
                        ),
                      ],
                    )
                  : _buildDashboard(isDark),
      floatingActionButton: null,
    );
  }

  Widget _buildDashboard(bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: KColors.primaryColor,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          children: [
            // 0. Community Global Health
            _buildGlobalCommunityStats(isDark),
            const SizedBox(height: 20),

            // 1. Personal Impact Header
            _buildPersonalImpactHeader(isDark),
            const SizedBox(height: 10),

            // 2. Quick Action
            _buildQuickJoinButton(isDark),
            const SizedBox(height: 20),

            // 2. Active Khatmahs Title
            _buildSectionTitle(
                isDark, 'الختمات الجارية', Icons.auto_stories_rounded),
            const SizedBox(height: 15),

            // 3. Campaigns List
            ...List.generate(_campaigns.length, (index) {
              return _buildCampaignCard(isDark, _campaigns[index], index);
            }),

            const SizedBox(height: 30),

            // 4. Global Leaderboard
            if (_globalLeaderboard.isNotEmpty) ...[
              _buildSectionTitle(isDark, 'قائمة الصدارة (أبرز المشاركين)',
                  Icons.emoji_events_rounded),
              const SizedBox(height: 15),
              _buildGlobalLeaderboard(isDark),
              const SizedBox(height: 30),
            ],

            // 5. Recent Activity Feed
            if (_recentGlobalActivity.isNotEmpty) ...[
              _buildSectionTitle(isDark, 'آخر مساهمات المجتمع',
                  Icons.record_voice_over_rounded),
              const SizedBox(height: 15),
              _buildRecentGlobalActivity(isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(bool isDark, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: KColors.primaryColor, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize:ResponsiveUtil.isTablet(context)? 18:14.sp,

            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalImpactHeader(bool isDark) {
    final completed = _userStats['total_completed'] ?? 0;
    final percent = _userStats['community_percent'] ?? '0';

    return InkWell(
      onTap: () => _showPersonalAnalytics(),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [KColors.primaryColor.withOpacity(0.2), Colors.black26]
                : [KColors.primaryColor.withOpacity(0.05), Colors.white],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: KColors.primaryColor.withOpacity(0.1)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 8)),
                ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: KColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.analytics_rounded,
                      color: KColors.primaryColor, size:ResponsiveUtil.isTablet(context)? 28:25),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'تأثيرك في المجتمع',
                            style: GoogleFonts.cairo(
                              fontSize:ResponsiveUtil.isTablet(context)? 18:14.sp,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: KColors.primaryColor.withOpacity(0.5)),
                        ],
                      ),
                      Text(
                        _userNickname ?? 'مشارك مجهول',
                        style: GoogleFonts.cairo(
                          fontSize:ResponsiveUtil.isTablet(context)? 13:13.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: _buildDashboardStatCard(
                    'ختماتي',
                    completed.toString(),
                    Icons.check_circle_rounded,
                    Colors.green,
                    isDark,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDashboardStatCard(
                    'نسبة التأثير',
                    '$percent%',
                    Icons.speed_rounded,
                    Colors.cyan,
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'اضغط لعرض التحليل التفصيلي للختمات',
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: KColors.primaryColor.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStatCard(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon(icon, color: color, size: 20),
          // const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalLeaderboard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withOpacity(0.1)),
      ),
      child: Column(
        children: List.generate(_globalLeaderboard.length, (index) {
          final entry = _globalLeaderboard[index];
          final name = entry['user_name'];
          final count = entry['completed_count'];
          final isTop = index < 3;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isTop
                  ? Colors.amber.withOpacity(isDark ? 0.05 : 0.03)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor:
                      isTop ? Colors.amber : Colors.grey.withOpacity(0.2),
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isTop ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Text(
                  '$count ورد',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w900,
                    color: KColors.primaryColor,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecentGlobalActivity(bool isDark) {
    return Column(
      children: _recentGlobalActivity.map((activity) {
        final name = activity['user_name'] ?? 'مشارك';
        final index = activity['item_index'];
        final campaignTitle =
            activity['community_campaigns']?['title'] ?? 'حمـلة';
        final type = activity['community_campaigns']?['target_type'] ?? 'juz';
        final typeLabel =
            type == 'juz' ? 'جزء' : (type == 'surah' ? 'سورة' : 'صفحة');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.03)
                : Colors.blueGrey.withOpacity(0.02),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flash_on_rounded,
                    color: Colors.green, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.cairo(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                          text: name,
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                      const TextSpan(text: ' أتم قراءة '),
                      TextSpan(
                        text: '$typeLabel $index',
                        style: TextStyle(
                            color: KColors.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' في '),
                      TextSpan(
                          text: campaignTitle,
                          style: const TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
              Text(
                _formatRelativeTime(activity['updated_at']),
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatRelativeTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp.toString());
      final diff = DateTime.now().difference(dt);

      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
      return '${dt.day}/${dt.month}';
    } catch (e) {
      return '';
    }
  }

  Widget _buildCampaignCard(
      bool isDark, Map<String, dynamic> campaign, int index) {
    final title = campaign['title'] ?? 'حمـلة';
    final targetType = campaign['target_type'] ?? 'juz';
    final typeLabel = targetType == 'juz'
        ? 'أجزاء'
        : (targetType == 'surah' ? 'سور' : 'صفحات');
    final completedCount = campaign['completed_count'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KColors.primaryColor.withOpacity(0.2)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: KColors.primaryColor.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8)),
              ],
      ),
      child: InkWell(
        onTap: () => _switchCampaign(index),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      spacing: 7,

                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.cairo(
                            fontSize:ResponsiveUtil.isTablet(context)? 20:13.sp,

                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'نشاط مجتمعي قائم بنظام ال $typeLabel',
                          style: GoogleFonts.cairo(
                            fontSize:ResponsiveUtil.isTablet(context)? 12:10.sp,

                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: KColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.keyboard_arrow_left_rounded,
                        color: KColors.primaryColor, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildMiniStat(Icons.auto_awesome,
                      '$completedCount ختمة مكتملة', Colors.amber),
                  const SizedBox(width: 15),
                  _buildMiniStat(
                      Icons.people_rounded, 'نشط الآن', Colors.green),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      KColors.primaryColor,
                      KColors.primaryColor.withOpacity(0.7)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                        color: KColors.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Text(
                    'انضم للختمة الآن',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize:ResponsiveUtil.isTablet(context)? 15:12.sp,

                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.cairo(
              fontSize:                              ResponsiveUtil.isTablet(context)? 11:10.sp
    , fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
    );
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (math.pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);
    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * math.cos(step),
          halfWidth + externalRadius * math.sin(step));
      path.lineTo(
          halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  void _shareProgress() {
    if (_campaigns.isEmpty) return;
    final campaign = _campaigns[_selectedCampaignIndex];
    final percent = (_completionPercent * 100).toInt();
    final title = campaign['title'] ?? 'الختمة الجماعية';
    final text = '🕋 شاركنا الأجر في "$title"\n'
        '📊 وصلنا الآن إلى انجاز $percent% من الختمة المباركة.\n'
        '✨ ساهم معنا بقراءة جزء أو سورة واجعل لك أثراً في ختم كتاب الله.\n'
        '📲 حمل تطبيق رفيق المسلم اليومي وشارك الآن!';
    Share.share(text);
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: 'ar_SA',
      );
      KHelper.showSuccess(message: 'أنا أسمعك.. قل رقم الجزء أو اسم السورة');
    } else {
      KHelper.showError(message: 'ميزة التعرف على الصوت غير متاحة حالياً');
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _onSpeechResult(result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });

    if (result.finalResult && _lastWords.isNotEmpty) {
      _stopListening();
      _processVoiceCommand(_lastWords);
    }
  }

  void _processVoiceCommand(String text) {
    if (text.isEmpty) return;

    setState(() {
      _searchQuery = text;
      _searchController.text = text;
    });

    final index = _parseSpeechToIndex(text);
    if (index != -1) {
      final statusData = _progress.firstWhere(
        (p) => p['item_index'] == index,
        orElse: () => {'status': 'available'},
      );
      final status = statusData['status'] ?? 'available';

      final type = _campaigns[_selectedCampaignIndex]['target_type'] ?? 'juz';
      String label = '';
      if (type == 'juz')
        label = 'جزء $index';
      else if (type == 'surah')
        label = _surahs.isNotEmpty && index <= _surahs.length
            ? _surahs[index - 1].name
            : 'سورة $index';
      else
        label = 'صفحة $index';

      _showActionSheet(index, status, label);
    } else {
      final type = _campaigns[_selectedCampaignIndex]['target_type'] ?? 'juz';
      String typeLabel = type == 'juz'
          ? 'رقم الجزء'
          : (type == 'surah' ? 'اسم السورة' : 'رقم الصفحة');
      KHelper.showNeutralFlushBar(context,
          'تم تحديث البحث: "$text". حاول قول $typeLabel لتحديد الورد مباشرة.');
    }
  }

  int _parseSpeechToIndex(String text) {
    // 0. Convert Arabic digits (١٢٣) to Latin (123)
    String processedText = text.replaceAllMapped(RegExp(r'[٠-٩]'), (match) {
      return (match.group(0)!.codeUnitAt(0) - 0x0660).toString();
    });

    final Map<String, int> numberMap = {
      'واحد': 1,
      '1': 1,
      'أول': 1,
      'اول': 1,
      'اثنين': 2,
      '2': 2,
      'ثاني': 2,
      'تاني': 2,
      'ثلاثة': 3,
      'ثلاثه': 3,
      '3': 3,
      'ثالث': 3,
      'اربعة': 4,
      'أربعة': 4,
      '4': 4,
      'رابع': 4,
      'خمسة': 5,
      'خمسه': 5,
      '5': 5,
      'خامس': 5,
      'ستة': 6,
      'سته': 6,
      '6': 6,
      'سادس': 6,
      'سبعة': 7,
      'سبعه': 7,
      '7': 7,
      'سابع': 7,
      'ثمانية': 8,
      'ثمانيه': 8,
      '8': 8,
      'ثامن': 8,
      'تسعة': 9,
      'تسعه': 9,
      '9': 9,
      'تاسع': 9,
      'عشرة': 10,
      'عشره': 10,
      'العاشر': 10,
      '10': 10,
      'أحد عشر': 11,
      '11': 11,
      'اثنا عشر': 12,
      '12': 12,
      'ثلاثة عشر': 13,
      '13': 13,
      'أربعة عشر': 14,
      '14': 14,
      'خمسة عشر': 15,
      '15': 15,
      'ستة عشر': 16,
      '16': 16,
      'سبعة عشر': 17,
      '17': 17,
      'ثمانية عشر': 18,
      '18': 18,
      'تسعة عشر': 19,
      '19': 19,
      'عشرون': 20,
      '20': 20,
      'واحد وعشرون': 21,
      'واحد وعشرين': 21,
      '21': 21,
      'اثنان وعشرون': 22,
      'اثنين وعشرين': 22,
      '22': 22,
      'ثلاثة وعشرون': 23,
      'ثلاثه وعشرين': 23,
      '23': 23,
      'أربعة وعشرون': 24,
      'اربعه وعشرين': 24,
      '24': 24,
      'خمسة وعشرون': 25,
      'خمسه وعشرين': 25,
      '25': 25,
      'ستة وعشرون': 26,
      'سته وعشرين': 26,
      '26': 26,
      'سبعة وعشرون': 27,
      'سبعه وعشرين': 27,
      '27': 27,
      'ثمانية وعشرون': 28,
      'ثمانيه وعشرين': 28,
      '28': 28,
      'تسعة وعشرون': 29,
      'تسعه وعشرين': 29,
      '29': 29,
      'ثلاثون': 30,
      'ثلاثين': 30,
      '30': 30,
    };

    // Clean text and check exact matches first
    final cleanText = processedText.trim();
    if (numberMap.containsKey(cleanText)) return numberMap[cleanText]!;

    // Extract numbers from text
    final words = cleanText.split(' ');
    final campaign = _campaigns[_selectedCampaignIndex];
    final targetTotal = campaign['target_total'] ?? 0;

    // Check for combined patterns
    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      if (numberMap.containsKey(word)) return numberMap[word]!;
      if (i < words.length - 1) {
        final combined = "$word ${words[i + 1]}";
        if (numberMap.containsKey(combined)) return numberMap[combined]!;
      }
    }

    // Fallback to digit parsing
    for (var word in words) {
      final intVal = int.tryParse(word);
      if (intVal != null && intVal > 0 && intVal <= targetTotal) return intVal;
    }

    // Extended mapping for surah names with normalization
    if (campaign['target_type'] == 'surah') {
      final normalizedVoiceInput = _normalizeArabic(cleanText);
      for (int i = 0; i < _surahs.length; i++) {
        final normalizedSurahName = _normalizeArabic(_surahs[i].name);
        if (normalizedVoiceInput.contains(normalizedSurahName)) return i + 1;
      }
    }

    return -1;
  }

  Widget _buildNoCampaign() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'لا توجد حملة نشطة حالياً',
            style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDark) {
    if (_campaigns.isEmpty) return const SizedBox();
    final campaign = _campaigns[_selectedCampaignIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(isDark, campaign),
          ),
          SliverToBoxAdapter(
            child: _buildMotivationalQuote(isDark),
          ),
          SliverToBoxAdapter(
            child: _buildSearchBar(isDark, campaign),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _buildGridSliver(campaign),
          ),
          SliverToBoxAdapter(
            child: _buildRecentActivity(isDark),
          ),
          SliverToBoxAdapter(
            child: _buildLeaderboard(isDark),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(bool isDark) {
    // Aggregate completed items by user name
    final Map<String, int> scores = {};
    for (var item in _progress) {
      if (item['status'] == 'completed') {
        final name = item['user_name']?.toString() ?? 'متسابق مجهول';
        scores[name] = (scores[name] ?? 0) + 1;
      }
    }

    if (scores.isEmpty) return const SizedBox();

    final sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: Colors.amber, size: 24),
              const SizedBox(width: 10),
              Text(
                'لوحة الصدارة المحلية',
                style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber.withOpacity(0.15)),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
            ),
            child: Column(
              children: sortedEntries.take(5).map((entry) {
                final index = sortedEntries.indexOf(entry);
                final isTop = index < 3;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isTop
                        ? Colors.amber.withOpacity(isDark ? 0.05 : 0.03)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            isTop ? Colors.amber : Colors.grey.withOpacity(0.2),
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isTop ? Colors.black87 : Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.value} ورد',
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w900,
                            color: KColors.primaryColor),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(bool isDark) {
    // Show activity even if user_name is null (for older records)
    final activity = _progress.toList()
      ..sort((a, b) => (b['updated_at']?.toString() ?? '')
          .compareTo(a['updated_at']?.toString() ?? ''));

    if (activity.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded,
                  color: KColors.primaryColor.withOpacity(0.7), size: 22),
              const SizedBox(width: 10),
              Text(
                'آخر المشاركات بالتفصيل',
                style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...activity.take(5).map((item) {
            final isDone = item['status'] == 'completed';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : Colors.blueGrey.withOpacity(0.01),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDone ? Colors.green : Colors.amber)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.menu_book_rounded,
                      size: 18,
                      color: isDone ? Colors.green : Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['user_name'] ?? 'أحد المتسابقين'}',
                          style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              height: 1.2),
                        ),
                        Text(
                          '${isDone ? 'أتم قراءة' : 'بدأ قراءة'} ورد رقم ${item['item_index']}',
                          style: GoogleFonts.cairo(
                              fontSize: 12, color: Colors.grey, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatRelativeTime(item['updated_at']),
                    style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // _formatTime removed in favor of _formatRelativeTime

  Widget _buildHeader(bool isDark, Map<String, dynamic> campaign) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      decoration: BoxDecoration(
        color: KColors.primaryColor.withOpacity(isDark ? 0.05 : 0.02),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [KColors.primaryColor, Colors.blueAccent],
            ).createShader(bounds),
            child: Text(
              campaign['title'] ?? 'بدون عنوان',
              style: GoogleFonts.cairo(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 25),
          _buildProgressIndicator(isDark, campaign),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي الختمات',
                  (campaign['completed_count'] ?? 0).toString(),
                  Icons.auto_awesome,
                  isDark: isDark,
                  cardColor: Colors.amber,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  'مساهمتي',
                  _myCompletedCount.toString(),
                  Icons.stars,
                  isDark: isDark,
                  cardColor: Colors.cyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalQuote(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KColors.primaryColor.withOpacity(0.1)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
      ),
      child: Column(
        children: [
          Icon(Icons.format_quote_rounded,
              color: KColors.primaryColor.withOpacity(0.5), size: 24),
          const SizedBox(height: 8),
          Text(
            _currentQuote,
            style: GoogleFonts.cairo(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int get _myCompletedCount {
    if (_userNickname == null) return 0;
    // Count items in _progress that are 'completed' and match my nickname
    return _progress
        .where((p) =>
            (p['status'] ?? '') == 'completed' &&
            (p['user_name']?.toString() == _userNickname))
        .length;
  }

  String _getCampaignTitleForId(dynamic id) {
    if (id == null) return 'حمـلة';
    final campaign = _campaigns.firstWhere(
      (c) => c['id'].toString() == id.toString(),
      orElse: () => {'title': 'حمـلة'},
    );
    return campaign['title'];
  }

  Widget _buildProgressIndicator(bool isDark, Map<String, dynamic> campaign) {
    final percent = _completionPercent;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تقدم الختمة الحالية',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold, color: KColors.primaryColor,
                fontSize:ResponsiveUtil.isTablet(context)? 12:10.sp,

              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              LinearProgressIndicator(
                value: percent,
                minHeight: 18,
                backgroundColor: KColors.primaryColor.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(KColors.primaryColor),
              ),
              if (percent > 0.05)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (percent > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              ' تم إنجاز ${(percent * campaign['target_total']).toInt()} من ${campaign['target_total']} حتى الآن!',
              style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
          )
        // 🎉
        else if (_progress.any((p) => (p['status'] ?? '') == 'reading'))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '👈 اضغط على الجزء الأصفر مرة أخرى بعد القراءة لإتمامه (سيتحول للأخضر)',
              style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon,
      {bool isDark = false, Color cardColor = Colors.amber}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: cardColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10)),
        ],
        border: Border.all(
            color: cardColor.withOpacity(isDark ? 0.3 : 0.1), width: 1.5),
      ),
      child: Column(
        spacing: 2,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cardColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.1,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGridSliver(Map<String, dynamic> campaign) {
    final int total = (campaign['target_total'] ?? 0) as int;
    if (total == 0) return const SliverToBoxAdapter(child: SizedBox());

    final filteredIndices =
        List.generate(total, (i) => i + 1).where((itemIndex) {
      if (_searchQuery.isEmpty) return true;

      final type = campaign['target_type'] ?? 'juz';
      String label = '';
      if (type == 'juz')
        label = 'جزء $itemIndex';
      else if (type == 'surah')
        label = _surahs.isNotEmpty && itemIndex <= _surahs.length
            ? _surahs[itemIndex - 1].name
            : 'سورة $itemIndex';
      else
        label = 'صفحة $itemIndex';

      final normalizedQuery = _normalizeArabic(_searchQuery);
      final normalizedLabel = _normalizeArabic(label);

      return normalizedLabel.contains(normalizedQuery) ||
          itemIndex.toString().contains(_searchQuery);
    }).toList();

    if (filteredIndices.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Icons.search_off_rounded,
                    size: 48, color: Colors.grey.withOpacity(0.5)),
                const SizedBox(height: 10),
                Text('لا توجد نتائج للبحث',
                    style: GoogleFonts.cairo(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final itemIndex = filteredIndices[index];
          final statusData = _progress.firstWhere(
            (p) => p['item_index'] == itemIndex,
            orElse: () => {'status': 'available'},
          );
          return _buildItemCard(campaign, itemIndex, statusData);
        },
        childCount: filteredIndices.length,
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> campaign, int index,
      Map<String, dynamic> statusData) {
    Color color;
    IconData icon;
    String label = '';
    final status = statusData['status'] ?? 'available';
    final readerName = statusData['user_name'];

    final type = campaign['target_type'] ?? 'juz';
    if (type == 'juz')
      label = 'جزء $index';
    else if (type == 'surah')
      label = _surahs.isNotEmpty && index <= _surahs.length
          ? _surahs[index - 1].name
          : 'سورة $index';
    else
      label = 'صفحة $index';

    switch (status) {
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'reading':
        color = Colors.amber;
        icon = Icons.menu_book;
        break;
      default:
        color = Colors.grey;
        icon = Icons.add_circle_outline;
    }

    final bool isMine = _myClaims.contains(index);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _showActionSheet(index, status, label),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.08) : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: color.withOpacity(status == 'available' ? 0.1 : 0.4),
              width: 2),
          boxShadow: [
            if (status != 'available')
              BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
          ],
        ),
        child: Stack(
          children: [
            if (status == 'completed')
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.verified_rounded, color: color, size: 16),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (status == 'reading')
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isMine ? 'من نصيبك' : (readerName ?? 'يُقرأ'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: color,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  Icon(icon,
                      color: color.withOpacity(status == 'available' ? 0.5 : 1),
                      size: 32),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color:
                            color.withOpacity(status == 'available' ? 0.8 : 1),
                        height: 1.1),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionSheet(int index, String status, String label) {
    if (status == 'completed') {
      KHelper.showSuccess(
          message: 'تم ختم هذا الورد بالفعل، يمكنك اختيار ورد آخر');
      return;
    }

    final bool isMine = _myClaims.contains(index);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'مشاركة في الختمة الجماعية',
                style: GoogleFonts.cairo(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'هل تود المساهمة بقراءة $label؟',
                style: GoogleFonts.cairo(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (status == 'available')
                ElevatedButton(
                  onPressed: () => _updateStatus(index, 'reading'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('أنا سأقرأه',
                      style: GoogleFonts.cairo(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              if (status == 'reading' && isMine)
                ElevatedButton(
                  onPressed: () => _updateStatus(index, 'completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('تمت القراءة بحمد الله',
                      style: GoogleFonts.cairo(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              if (status != 'completed') ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToQuran(index);
                  },
                  icon: const Icon(Icons.menu_book_rounded, color: Colors.teal),
                  label: Text('قراءة من المصحف',
                      style: GoogleFonts.cairo(
                          color: Colors.teal, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
              if (status == 'reading' && !isMine)
                const Text('شخص آخر يقوم بقراءة هذا الورد حالياً',
                    style: TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToQuran(int index) {
    final campaign = _campaigns[_selectedCampaignIndex];
    final type = campaign['target_type'] ?? 'juz';

    int pageIndex = 0;
    int targetPage = 0;
    final campaignId = campaign['id']?.toString();

    try {
      if (type == 'surah') {
        // Surah index from Khatmah is 1-based (Surah 1, Surah 2...)
        pageIndex = quran.getPageNumber(index, 1) - 1;
        targetPage = quran.getPageNumber(index, quran.getVerseCount(index)) - 1;
      } else if (type == 'juz') {
        // Juz index is 1-based (Juz 1, Juz 2...)
        // Standard Medina Mushaf Juz start pages
        final juzPages = [
          1,
          22,
          42,
          62,
          82,
          102,
          122,
          142,
          162,
          182,
          202,
          222,
          242,
          262,
          282,
          302,
          322,
          342,
          362,
          382,
          402,
          422,
          442,
          462,
          482,
          502,
          522,
          542,
          562,
          582
        ];
        if (index > 0 && index <= 30) {
          pageIndex = juzPages[index - 1] - 1;
          targetPage = (index < 30) ? juzPages[index] - 2 : 603;
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuranView(
            initialPage: pageIndex,
            campaignId: campaignId,
            targetPage: targetPage,
            onConfirm: () async {
              // Update status and pop back
              await _updateStatus(index, 'completed');
              if (mounted) {
                Navigator.pop(context);
                KHelper.showSuccess(message: 'تم تسجيل القراءة بنجاح ✅');
              }
            },
          ),
        ),
      );
    } catch (e) {
      print('Error calculating Quran page: $e');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QuranView(),
        ),
      );
    }
  }

  Future<void> _updateStatus(int index, String status) async {
    await _ensureNickname();
    if (_userNickname == null || _userNickname!.isEmpty) return;

    Navigator.pop(context); // Close sheet

    if (_campaigns.isEmpty) return;
    final campaignId = _campaigns[_selectedCampaignIndex]['id'];
    if (campaignId == null) return;

    final success = await _service.updateItemStatus(campaignId, index, status,
        userName: _userNickname);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      if (status == 'reading') {
        _myClaims.add(index);
      } else if (status == 'completed') {
        _myClaims.remove(index);
      }
      await prefs.setStringList('my_global_claims_$campaignId',
          _myClaims.map((e) => e.toString()).toList());

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              // Local update for immediate feedback (Realtime will also update but this is faster)
              final existingIndex =
                  _progress.indexWhere((p) => p['item_index'] == index);
              if (existingIndex != -1) {
                _progress[existingIndex]['status'] = status;
              } else {
                _progress.add({'item_index': index, 'status': status});
              }

              if (_completionPercent >= 1.0) {
                _confettiController.play();
              }
            });
          }
        });
      }

      KHelper.showSuccess(message: 'تم تحديث الحالة بنجاح.. جزاك الله خيراً');

      // 🔄 Refresh user stats to update dashboard immediately
      if (status == 'completed') {
        await _refreshUserStats();
      }

      // 🔔 Handle Notifications
      if (status == 'reading') {
        final campaign = _campaigns[_selectedCampaignIndex];
        String label = 'الورد رقم $index';

        final type = campaign['target_type'] ?? 'juz';
        if (type == 'juz')
          label = 'الجزء $index';
        else if (type == 'surah')
          label = _surahs.isNotEmpty && index <= _surahs.length
              ? 'سورة ${_surahs[index - 1].name}'
              : 'السورة رقم $index';

        await NotificationManager()
            .scheduleCommunityKhatmahReminder(index: index, label: label);
      } else {
        // Cancel notification if completed or cancelled
        await NotificationManager().cancelCommunityKhatmahReminder(index);
      }
    } else {
      KHelper.showError(message: 'فشل التحديث، يرجى التحقق من اتصال الإنترنت');
    }
  }

  Future<void> _showPersonalAnalytics() async {
    if (_userNickname == null) {
      KHelper.showError(message: "يرجى تسجيل اسمك أولاً عبر المشاركة في أي ورد");
      // KHelper.showNeutralFlushBar(
      //     context, 'يرجى تسجيل اسمك أولاً عبر المشاركة في أي ورد');
      return;
    }

    final campaignId =
        _isDetailView ? _campaigns[_selectedCampaignIndex]['id'] : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AnalyticsBottomSheet(
        userName: _userNickname!,
        service: _service,
        campaignId: campaignId,
        campaigns: _campaigns,
        selectedCampaignIndex: _selectedCampaignIndex,
        onSwitchCampaign: _switchCampaign,
      ),
    );
  }

  void _showHelpDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppThemeColors.cardBackgroundColor(context),
          shape: BeveledRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(15.r)),
          title: Row(
            children: [
              Icon(Icons.help_outline_rounded, color: KColors.primaryColor),
              const SizedBox(width: 10),
              Text('كيف أشارك؟',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpItem('1. اختر الورد',
                    'تصفح الأجزاء أو السور المتاحة (باللون الرمادي).'),
                _buildHelpItem('2. احجز القراءة',
                    'اضغط على الورد واختر "أنا سأقرأه". سيتحول للون الأصفر.'),
                _buildHelpItem(
                    '3. اقرأ بتدبر', 'اقرأ الورد من المصحف أو من التطبيق.'),
                _buildHelpItem('4. أكد الإتمام',
                    'بعد الانتهاء، عد للتطبيق واضغط على نفس الورد واختر "تمت القراءة". سيتحول للأخضر.'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '💡 ملاحظة: إذا حجزت ورداً ولم تكمله خلال 24 ساعة، سيعود متاحاً للآخرين تلقائياً.',
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('فهمت، شكراً',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(desc,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  PopupMenuItem<_KhatmahMenuAction> _buildKhatmahMenuItem({
    required _KhatmahMenuAction value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return PopupMenuItem<_KhatmahMenuAction>(
      value: value,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: isDark ? Colors.white60 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalCommunityStats(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KColors.primaryColor.withOpacity(isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KColors.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.public_rounded, color: KColors.primaryColor, size: 24),
              const SizedBox(width: 10),
              Text(
                'إحصائيات مجتمع رفيق المسلم اليومي',
                style: GoogleFonts.cairo(
                  fontSize:ResponsiveUtil.isTablet(context)? 16:14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSimpleStat(
                  'إجمالي الختمات',
                  _communityGlobalStats['total_completed'].toString(),
                  Icons.auto_awesome,
                  Colors.amber),
              _buildSimpleStat(
                  'يقرؤون الآن',
                  _communityGlobalStats['active_readers'].toString(),
                  Icons.people_rounded,
                  Colors.blue),
              _buildSimpleStat(
                  'إنجازات اليوم',
                  _communityGlobalStats['today_completions'].toString(),
                  Icons.today_rounded,
                  Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon(icon, color: color, size: 20),
          // const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Map<String, dynamic> campaign) {
    final type = campaign['target_type'] ?? 'juz';
    String hint = 'البحث عن رقم الجزء...';
    if (type == 'surah')
      hint = 'البحث عن اسم السورة...';
    else if (type == 'page') hint = 'البحث عن رقم الصفحة...';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppThemeColors.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppThemeColors.cardBorderColor(context),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.cairo(
            fontSize: 13,
            color: isDark ? Colors.white54 : Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 22,
            color:
                isDark ? Colors.white70 : KColors.primaryColor.withOpacity(0.7),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.cancel_rounded, size: 20),
                  color: isDark ? Colors.white38 : Colors.grey[400],
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    size: 22,
                    color:
                        _isListening ? Colors.redAccent : KColors.primaryColor,
                  ),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickJoinButton(bool isDark) {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _joinRandomWard,
        icon: const Icon(Icons.bolt_rounded, size: 20, color: Colors.amber),
        label: Text('انضم إلى ورد عشوائي الآن',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          foregroundColor: isDark ? Colors.amber[300] : Colors.amber[800],
          side: BorderSide(color: Colors.amber.withOpacity(0.4), width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }

  void _joinRandomWard() {
    if (_campaigns.isEmpty) return;

    // Pick first active campaign for simplicity
    setState(() {
      _selectedCampaignIndex = 0;
      _isDetailView = true;
    });
    _switchCampaign(0);

    KHelper.showSuccess(
        message: 'تم اختيار حملة الختمة الجارية، ابحث عن ورد متاح!');
  }

  String _normalizeArabic(String text) {
    if (text.isEmpty) return text;
    // Normalize Alef variants
    String normalized = text.replaceAll(RegExp(r'[أإآ]'), 'ا');
    // Normalize Te Marbuta
    normalized = normalized.replaceAll('ة', 'ه');
    // Normalize Ya variants
    normalized = normalized.replaceAll('ى', 'ي');
    // Remove Arabic diacritics (Tashkeel)
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u0652]'), '');
    return normalized.trim();
  }
}

class _AnalyticsBottomSheet extends StatelessWidget {
  final String userName;
  final GlobalKhatmahService service;
  final String? campaignId;
  final List<Map<String, dynamic>> campaigns;
  final int selectedCampaignIndex;
  final Function(int) onSwitchCampaign;

  const _AnalyticsBottomSheet({
    required this.userName,
    required this.service,
    required this.campaigns,
    required this.selectedCampaignIndex,
    required this.onSwitchCampaign,
    this.campaignId,
  });

  String _getCampaignTitleForId(dynamic id) {
    if (id == null) return 'حمـلة';
    final campaign = campaigns.firstWhere(
      (c) => c['id'].toString() == id.toString(),
      orElse: () => {'title': 'حمـلة'},
    );
    return campaign['title'];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = KColors.primaryColor;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFF8FAFC), Colors.white],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 25),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [primaryColor, Colors.blueAccent],
            ).createShader(bounds),
            child: Text(
              'تحليل القراءة الشخصي',
              style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white),
            ),
          ),
          Text(
            campaignId == null
                ? 'أداؤك ومساهمتك في جميع الختمات'
                : 'أداؤك ومساهمتك في هذه الختمة',
            style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? Colors.blueGrey[300] : Colors.grey[600],
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future:
                  service.getUserKhatmahStats(userName, campaignId: campaignId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: KLoading.progressIOSIndicator(
                          context: context, progressColor: primaryColor));
                }

                final stats = snapshot.data ??
                    {
                      'total_completed': 0,
                      'community_percent': '0',
                      'history': []
                    };
                final totalCount = stats['total_completed'] as int;
                final commPercent =
                    double.tryParse(stats['community_percent'].toString()) ??
                        0.0;
                final history = (stats['history'] as List).reversed.toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildImpactCard(
                                'إنجازاتي',
                                totalCount.toString(),
                                Icons.auto_awesome,
                                Colors.amber,
                                isDark)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: _buildImpactCard('التأثير', '$commPercent%',
                                Icons.speed_rounded, Colors.cyan, isDark)),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildChartSection(
                        commPercent, totalCount, isDark, primaryColor),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Icon(Icons.history_rounded,
                            color: primaryColor, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'سجل الإنجازات الأخيرة',
                          style: GoogleFonts.cairo(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (history.isEmpty)
                      _buildEmptyState(isDark)
                    else
                      ...history.take(15).map((item) =>
                          _buildHistoryItem(item, isDark, primaryColor)),
                    const SizedBox(height: 50),
                    const SizedBox(height: 50),
                    if (totalCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      KhatmahCertificateScreen(
                                    userName: userName,
                                    contributionCount: totalCount,
                                    campaignTitle: campaignId != null
                                        ? _getCampaignTitleForId(campaignId)
                                        : 'ختمة جماعية',
                                    date: DateTime.now(),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.workspace_premium_rounded,
                                color: Colors.white),
                            label: Text('استلام شهادة تقدير',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[700],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.3 : 0.1),
          width: 1.5,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 15),
          Text(value,
              style: GoogleFonts.cairo(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1,
              )),
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChartSection(
      double percent, int count, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.02)
            : Colors.blueGrey.withOpacity(0.03),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Text(
            'مساهمتي مقابل الختمات الكلية',
            style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 25),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 5,
                    centerSpaceRadius: 65,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: percent,
                        title: '',
                        color: primaryColor,
                        radius: 18,
                        badgeWidget: _buildChartBadge('$percent%'),
                        badgePositionPercentageOffset: 1.2,
                      ),
                      PieChartSectionData(
                        value: (100 - percent).clamp(0, 100),
                        title: '',
                        color: isDark
                            ? Colors.white12
                            : Colors.grey.withOpacity(0.1),
                        radius: 12,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    count.toString(),
                    style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: primaryColor),
                  ),
                  Text(
                    'ورد مكتمل',
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        height: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: KColors.primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHistoryItem(dynamic item, bool isDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child:
                Icon(Icons.check_circle_rounded, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أتممت ورد رقم ${item['item_index'] ?? '؟؟'}',
                  style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87),
                ),
                Text(
                  campaignId != null
                      ? _formatDate(item['updated_at'])
                      : '${_formatDate(item['updated_at'])} • في ${_getCampaignTitleForId(item['campaign_id'])}',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'مكتمل',
              style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.auto_stories_outlined,
                size: 60, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 15),
            Text(
              'ابدأ رحلتك اليوم!',
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'شارك في قراءة ورد لتبدأ في جمع النقاط والأوسمة',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return '';
    }
  }
}
