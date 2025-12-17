import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/style/responsive_util.dart';
import 'dart:convert';

class VirtualShopScreen extends StatefulWidget {
  final int currentStars;
  final Function(int) onPurchase;

  const VirtualShopScreen({
    super.key,
    required this.currentStars,
    required this.onPurchase,
  });

  @override
  State<VirtualShopScreen> createState() => _VirtualShopScreenState();
}

class _VirtualShopScreenState extends State<VirtualShopScreen> {
  Set<String> _purchasedItems = {};

  final List<Map<String, dynamic>> _shopItems = [
    {
      'id': 'theme_blue',
      'name': 'ثيم أزرق سماوي',
      'emoji': '🌊',
      'type': 'theme',
      'cost': 50,
      'description': 'لون أزرق جميل للواجهة',
    },
    {
      'id': 'theme_green',
      'name': 'ثيم أخضر طبيعي',
      'emoji': '🌿',
      'type': 'theme',
      'cost': 50,
      'description': 'لون أخضر مريح للعين',
    },
    {
      'id': 'badge_gold',
      'name': 'وسام ذهبي',
      'emoji': '🏅',
      'type': 'badge',
      'cost': 100,
      'description': 'وسام ذهبي خاص',
    },
    {
      'id': 'badge_diamond',
      'name': 'وسام الماس',
      'emoji': '💎',
      'type': 'badge',
      'cost': 150,
      'description': 'وسام نادر وقيم',
    },
    {
      'id': 'avatar_superhero',
      'name': 'بطل خارق',
      'emoji': '🦸',
      'type': 'avatar',
      'cost': 150,
      'description': 'صورة رمزية بطل خارق',
    },
    {
      'id': 'avatar_scientist',
      'name': 'عالم صغير',
      'emoji': '🥼',
      'type': 'avatar',
      'cost': 150,
      'description': 'صورة رمزية عالم',
    },
    {
      'id': 'background_space',
      'name': 'خلفية الفضاء',
      'emoji': '🌌',
      'type': 'background',
      'cost': 200,
      'description': 'خلفية فضائية رائعة',
    },
    {
      'id': 'background_nature',
      'name': 'خلفية الطبيعة',
      'emoji': '🏞️',
      'type': 'background',
      'cost': 200,
      'description': 'خلفية طبيعية خضراء',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _purchasedItems = (prefs.getStringList('purchased_items') ?? []).toSet();
    });
  }

  Future<void> _savePurchases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('purchased_items', _purchasedItems.toList());
  }

  void _buyItem(Map<String, dynamic> item) {
    final cost = item['cost'] as int;

    if (widget.currentStars < cost) {
      _showInsufficientStarsDialog();
      return;
    }

    if (_purchasedItems.contains(item['id'])) {
      _showAlreadyOwnedDialog();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تأكيد الشراء',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل تريد شراء ${item['name']} بـ $cost نجمة؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _purchasedItems.add(item['id']);
                widget.onPurchase(cost);
              });
              _savePurchases();
              _showPurchaseSuccessDialog(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'شراء',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInsufficientStarsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('⭐'),
            const SizedBox(width: 8),
            Text(
              'نجوم غير كافية',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'احصل على المزيد من النجوم بإكمال المهام والألعاب!',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  void _showAlreadyOwnedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تملكه بالفعل',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'لديك هذا العنصر بالفعل!',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  void _showPurchaseSuccessDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🎉'),
            const SizedBox(width: 8),
            Text(
              'تم الشراء!',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'تهانينا! حصلت على ${item['name']} ${item['emoji']}',
          style: GoogleFonts.cairo(fontSize: 16.sp),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: Text(
              'رائع!',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group items by type
    final Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (var item in _shopItems) {
      final type = item['type'] as String;
      if (!groupedItems.containsKey(type)) {
        groupedItems[type] = [];
      }
      groupedItems[type]!.add(item);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'المتجر 🏪',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtil.isTablet(context) ? 14.sp : 20.sp,
            ),
          ),
          centerTitle: true,
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.currentStars}',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
                'الثيمات', groupedItems['theme'] ?? [], isDark, Colors.blue),
            const SizedBox(height: 20),
            _buildSection(
                'الأوسمة', groupedItems['badge'] ?? [], isDark, Colors.amber),
            const SizedBox(height: 20),
            _buildSection('الصور الرمزية', groupedItems['avatar'] ?? [], isDark,
                Colors.purple),
            const SizedBox(height: 20),
            _buildSection('الخلفيات', groupedItems['background'] ?? [], isDark,
                Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items,
      bool isDark, Color color) {
    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: ResponsiveUtil.isTablet(context) ? 12.sp : 18.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildShopItem(item, isDark, color)),
      ],
    );
  }

  Widget _buildShopItem(Map<String, dynamic> item, bool isDark, Color color) {
    final isOwned = _purchasedItems.contains(item['id']);
    final canAfford = widget.currentStars >= (item['cost'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOwned
              ? Colors.green
              : (canAfford ? color.withOpacity(0.3) : Colors.grey.shade300),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (isOwned ? Colors.green : color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              item['emoji'],
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item['name'],
                style: GoogleFonts.cairo(
                  fontSize: ResponsiveUtil.isTablet(context) ? 10.sp : 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (isOwned)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['description'],
              style: GoogleFonts.cairo(
                fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 11.sp,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${item['cost']}',
                  style: GoogleFonts.cairo(
                    fontSize: ResponsiveUtil.isTablet(context) ? 9.sp : 12.sp,
                    fontWeight: FontWeight.bold,
                    color: canAfford ? Colors.amber : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isOwned
            ? null
            : ElevatedButton(
                onPressed: () => _buyItem(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford ? color : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'شراء',
                  style: GoogleFonts.cairo(
                    fontSize: ResponsiveUtil.isTablet(context) ? 8.sp : 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}
