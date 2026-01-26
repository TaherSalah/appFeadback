import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:intl/intl.dart';
import 'models/MosqueModel.dart';
import 'services/MosqueService.dart';

class MosqueAdminPanel extends StatefulWidget {
  const MosqueAdminPanel({super.key});

  @override
  State<MosqueAdminPanel> createState() => _MosqueAdminPanelState();
}

class _MosqueAdminPanelState extends State<MosqueAdminPanel> {
  final MosqueService _mosqueService = MosqueService();
  List<Mosque> _allMosques = [];
  bool _isLoading = true;
  Map<String, int> _deviceStats = {};

  @override
  void initState() {
    super.initState();
    _loadAllMosques();
  }

  Future<void> _loadAllMosques() async {
    setState(() => _isLoading = true);

    try {
      // Fetch all user mosques (we'll use a dummy location for distance calculation)
      final mosques = await _mosqueService.fetchNearbyMosques(
        latitude: 0,
        longitude: 0,
        radiusMeters: 999999999,
      );

      // Filter only user-added mosques
      final userMosques = mosques.where((m) => m.isUserAdded).toList();

      // Calculate device statistics
      final Map<String, int> stats = {};
      for (var mosque in userMosques) {
        final deviceId = mosque.deviceId ?? 'unknown';
        stats[deviceId] = (stats[deviceId] ?? 0) + 1;
      }

      setState(() {
        _allMosques = userMosques;
        _deviceStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      KHelper.showError(message: "حدث خطأ أثناء تحميل البيانات");
    }
  }

  Future<void> _deleteMosque(Mosque mosque) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تأكيد الحذف",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text("هل أنت متأكد من حذف ${mosque.name}؟",
            style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("إلغاء", style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text("حذف", style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _mosqueService.deleteUserMosque(mosque.id);
      if (success) {
        KHelper.showSuccess(message: "تم الحذف بنجاح");
        _loadAllMosques();
      } else {
        KHelper.showError(message: "فشل الحذف");
      }
    }
  }

  void _editMosque(Mosque mosque) {
    final nameController = TextEditingController(text: mosque.name);
    final addressController = TextEditingController(text: mosque.address);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تعديل المسجد",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "اسم المسجد",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: "العنوان",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء", style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _mosqueService.updateUserMosque(
                id: mosque.id,
                name: nameController.text,
                address: addressController.text,
              );
              if (success) {
                KHelper.showSuccess(message: "تم التحديث بنجاح");
                _loadAllMosques();
              } else {
                KHelper.showError(message: "فشل التحديث");
              }
            },
            child: Text("حفظ", style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إدارة المساجد",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Statistics Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "إحصائيات المساجد",
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                              "إجمالي المساجد", _allMosques.length.toString()),
                          _buildStatItem(
                              "عدد الأجهزة", _deviceStats.length.toString()),
                        ],
                      ),
                    ],
                  ),
                ),

                // Mosques List
                Expanded(
                  child: _allMosques.isEmpty
                      ? Center(
                          child: Text(
                            "لا توجد مساجد مضافة",
                            style: GoogleFonts.cairo(fontSize: 16.sp),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _allMosques.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final mosque = _allMosques[index];
                            final deviceId = mosque.deviceId ?? 'unknown';
                            final shortDeviceId = deviceId.length > 8
                                ? deviceId.substring(0, 8)
                                : deviceId;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.mosque,
                                      color: Colors.orange),
                                ),
                                title: Text(
                                  mosque.name,
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mosque.address,
                                      style: GoogleFonts.cairo(fontSize: 11.sp),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(Icons.phone_android,
                                            size: 12, color: Colors.grey),
                                        SizedBox(width: 4.w),
                                        Text(
                                          "الجهاز: $shortDeviceId",
                                          style: GoogleFonts.cairo(
                                            fontSize: 10.sp,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue, size: 20),
                                      onPressed: () => _editMosque(mosque),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red, size: 20),
                                      onPressed: () => _deleteMosque(mosque),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
