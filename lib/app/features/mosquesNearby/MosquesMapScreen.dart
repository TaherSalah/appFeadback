import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslimdaily/app/core/extensions/context_extension.dart';
import 'package:muslimdaily/app/core/utils/style/k_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/widgets/KLoading.dart';
import 'models/MosqueModel.dart';
import 'services/MosqueService.dart';
import '../../core/widgets/CustomGradientDialog.dart';

class MosquesMapScreen extends StatefulWidget {
  const MosquesMapScreen({super.key});

  @override
  State<MosquesMapScreen> createState() => _MosquesMapScreenState();
}

class _MosquesMapScreenState extends State<MosquesMapScreen> {
  final MapController _mapController = MapController();
  final MosqueService _mosqueService = MosqueService();

  List<Mosque> _mosques = [];
  Position? _userPosition;
  bool _isLoading = true;
  double _searchRadius = 5000; // meters
  Mosque? _selectedMosque;

  // New features state
  bool _isAddingMode = false;
  bool _isBottomSheetVisible = true; // للتحكم في إظهار/إخفاء القائمة السفلية
  LatLng? _pickedLocation;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initLocation();
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        KHelper.showError(message: "يرجى تفعيل خدمة الموقع");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        KHelper.showError(message: "تم رفض إذن الموقع");
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      if (mounted) {
        setState(() {
          _userPosition = position;
        });

        _fetchMosques();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMosques() async {
    if (_userPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    final mosques = await _mosqueService.fetchNearbyMosques(
      latitude: _userPosition!.latitude,
      longitude: _userPosition!.longitude,
      radiusMeters: _searchRadius.toInt(),
    );

    if (mounted) {
      setState(() {
        _mosques = mosques;
        _isLoading = false;
      });
    }
  }

  void _onMosqueSelected(Mosque mosque) {
    setState(() {
      _selectedMosque = mosque;
    });

    _mapController.move(
      LatLng(mosque.latitude, mosque.longitude),
      16,
    );
  }

  void _openDirections(Mosque mosque) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmLocation() async {
    final center = _mapController.camera.center;
    setState(() {
      _pickedLocation = center;
    });

    // Try to get address
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        center.latitude,
        center.longitude,
        localeIdentifier: 'ar',
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _addressController.text =
            "${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}";
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }

    _showAddMosqueDialog();
  }

  void _showAddMosqueDialog() {
    _nameController.clear();
    _addressController.clear();
    _showMosqueFormDialog(isEditing: false);
  }

  void _showEditMosqueDialog(Mosque mosque) {
    _nameController.text = mosque.name;
    _addressController.text = mosque.address;
    _showMosqueFormDialog(isEditing: true, mosqueId: mosque.id);
  }

  void _showMosqueFormDialog({required bool isEditing, String? mosqueId}) {
    final bool isDark = context.isDark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
          child: Stack(
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
                        ? [const Color(0xFF0B2B1A), const Color(0xFF052014)]
                        : [const Color(0xFFF2FFF8), const Color(0xFFE1FFE8)],
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
                      isEditing ? "تعديل بيانات المسجد" : "إضافة مسجد جديد",
                         style: TextStyle(
                          fontFamily: "cairo",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        labelText: "اسم المسجد",
                        prefixIcon:
                            const Icon(Icons.mosque, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: Colors.green.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Colors.green, width: 2),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.black26 : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _addressController,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        labelText: "العنوان (اختياري)",
                        prefixIcon:
                            const Icon(Icons.location_on, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: Colors.green.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Colors.green, width: 2),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.black26 : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'إلغاء',
                                 style: TextStyle(
                          fontFamily: "cairo",
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (isEditing) {
                                _updateMosque(mosqueId!);
                              } else {
                                _saveMosque();
                              }
                              Navigator.of(dialogContext).pop();
                            },
                            icon: Icon(
                                isEditing ? Icons.check : Icons.add_location),
                            label: Text(isEditing ? 'تحديث' : 'حفظ',
                                   style: TextStyle(
                          fontFamily: "cairo",)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.teal],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isEditing
                            ? Icons.edit_location
                            : Icons.add_location_alt,
                        size: 34,
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
    );
  }

  Future<void> _updateMosque(String id) async {
    if (_nameController.text.isEmpty) {
      KHelper.showError(message: "يرجى إدخال اسم المسجد");
      return;
    }

    Navigator.pop(context);

    final success = await _mosqueService.updateUserMosque(
      id: id,
      name: _nameController.text,
      address: _addressController.text,
    );

    if (success) {
      KHelper.showSuccess(message: "تم تحديث البيانات بنجاح");
      _fetchMosques();
    } else {
      KHelper.showError(message: "حدث خطأ أثناء التحديث");
    }
  }

  Future<void> _confirmDelete(Mosque mosque) async {
    final bool isDark = context.isDark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: Colors.transparent,
          child: Stack(
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
                        ? [const Color(0xFF2B0B0B), const Color(0xFF200505)]
                        : [const Color(0xFFFFF2F2), const Color(0xFFFFE1E1)],
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
                      'حذف المسجد؟',
                         style: TextStyle(
                          fontFamily: "cairo",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'هل أنت متأكد من رغبتك في حذف "${mosque.name}"؟\n'
                      'لا يمكن التراجع عن هذه العملية.',
                         style: TextStyle(
                          fontFamily: "cairo",
                        fontSize: 14,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.red.withOpacity(0.06),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'سيتم حذف المسجد نهائياً من قاعدة البيانات.',
                                 style: TextStyle(
                          fontFamily: "cairo",
                                fontSize: 12.5,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                            child: Text(
                              'تراجع',
                                 style: TextStyle(
                          fontFamily: "cairo",
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                              final success = await _mosqueService
                                  .deleteUserMosque(mosque.id);
                              if (success) {
                                KHelper.showSuccess(
                                    message: "تم حذف المسجد بنجاح");
                                _fetchMosques();
                              } else {
                                KHelper.showError(
                                    message: "حدث خطأ أثناء الحذف");
                              }
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: Text('حذف',    style: TextStyle(
                          fontFamily: "cairo",)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.deepOrange],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.delete_forever_rounded,
                        size: 34,
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
    );
  }

  Future<void> _saveMosque() async {
    if (_nameController.text.isEmpty) {
      KHelper.showError(message: "يرجى إدخال اسم المسجد");
      return;
    }

    Navigator.pop(context); // Close dialog

    final success = await _mosqueService.addUserMosque(
      name: _nameController.text,
      address: _addressController.text,
      latitude: _pickedLocation!.latitude,
      longitude: _pickedLocation!.longitude,
    );

    if (success) {
      if (mounted) {
        KHelper.showSuccess(message: "تم حفظ المسجد بنجاح");
        _fetchMosques();
        setState(() {
          _isAddingMode = false;
          _nameController.clear();
          _addressController.clear();
        });
        _showOSMContributionOption();
      }
    } else {
      if (mounted) {
        KHelper.showError(message: "حدث خطأ أثناء الحفظ");
      }
    }
  }

  void _showOSMContributionOption() {
    final bool isDark = context.isDark;

    showDialog(
      context: context,
      builder: (context) => CustomGradientDialog(
        title: "المساهمة في الخريطة العالمية",
        message:
            "تمت إضافة المسجد لتطبيقك. هل ترغب في إضافته أيضاً لخريطة OpenStreetMap لتعم الفائدة عالمياً؟",
        icon: Icons.map_outlined,
        gradientColors: isDark
            ? [const Color(0xFF1E3A8A), const Color(0xFF172554)]
            : [const Color(0xFF60A5FA), const Color(0xFF2563EB)],
        isDark: isDark,
        onPrimaryPressed: () {
          Navigator.pop(context);
          _openOSMEditor();
        },
        primaryButtonText: "أضف الآن",
        primaryButtonColor: Colors.blue,
        onSecondaryPressed: () => Navigator.pop(context),
        secondaryButtonText: "لاحقاً",
        infoText:
            "إضافتك للمسجد على الخرايط العالمية بيسهل على ملايين المسلمين الوصول ليه. جزاك الله خيراً!",
      ),
    );
  }

  void _openOSMEditor() async {
    final lat = _pickedLocation!.latitude;
    final lon = _pickedLocation!.longitude;
    final name = _nameController.text;

    // Pass the name to the OSM note text parameter
    final url = Uri.parse(
        'https://www.openstreetmap.org/note/new?lat=$lat&lon=$lon&text=${Uri.encodeComponent("مسجد جديد: $name")}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      } else {
        // Fallback
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("Could not launch OSM: $e");
      KHelper.showError(
          message: "تعذر فتح المتصفح، يمكنك إضافة المسجد يدوياً من موقع OSM");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black45 : Colors.white70,
              shape: BoxShape.circle,
            ),
            child: CupertinoNavigationBarBackButton(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          centerTitle: true,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black45 : Colors.white70,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "المساجد القريبة",
                 style: TextStyle(
                          fontFamily: "cairo",
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [

            //// أداره المساجد كلها
            // Container(
            //   margin: const EdgeInsets.all(8),
            //   decoration: BoxDecoration(
            //     color: isDark ? Colors.black45 : Colors.white70,
            //     shape: BoxShape.circle,
            //   ),
            //   child: IconButton(
            //     icon:
            //         const Icon(Icons.admin_panel_settings, color: Colors.green),
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => const MosqueAdminPanel(),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black45 : Colors.white70,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.my_location, color: Colors.blue),
                onPressed: () {
                  if (_userPosition != null) {
                    _mapController.move(
                      LatLng(_userPosition!.latitude, _userPosition!.longitude),
                      14,
                    );
                  }
                },
              ),
            ),
          ],
        ),
        body: _userPosition == null
            ? Center(child: KLoading.progressIOSIndicator(context: context))
            : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                          _userPosition!.latitude, _userPosition!.longitude),
                      initialZoom: 14,
                      minZoom: 5,
                      maxZoom: 18,
                      onTap: (_, latlng) {
                        if (!_isAddingMode) {
                          setState(() => _selectedMosque = null);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.rafiq.muslimdaily',
                        tileBuilder: isDark
                            ? (context, tileWidget, tile) => ColorFiltered(
                                  colorFilter: const ColorFilter.matrix([
                                    -1,
                                    0,
                                    0,
                                    0,
                                    255,
                                    0,
                                    -1,
                                    0,
                                    0,
                                    255,
                                    0,
                                    0,
                                    -1,
                                    0,
                                    255,
                                    0,
                                    0,
                                    0,
                                    1,
                                    0,
                                  ]),
                                  child: tileWidget,
                                )
                            : null,
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_userPosition!.latitude,
                                _userPosition!.longitude),
                            width: 60,
                            height: 60,
                            child: Pulse(
                              infinite: true,
                              child: const Icon(Icons.person_pin_circle,
                                  color: Colors.blue, size: 45),
                            ),
                          ),
                          ..._mosques.map((mosque) {
                            final isSelected = _selectedMosque?.id == mosque.id;
                            return Marker(
                              point: LatLng(mosque.latitude, mosque.longitude),
                              width: isSelected ? 80 : 60,
                              height: isSelected ? 80 : 60,
                              child: GestureDetector(
                                onTap: () => _onMosqueSelected(mosque),
                                child: ZoomIn(
                                  duration: const Duration(milliseconds: 300),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.mosque,
                                        color: isSelected
                                            ? Colors.amber
                                            : (mosque.isUserAdded
                                                ? Colors.orange
                                                : Colors.green),
                                        size: isSelected ? 40 : 35,
                                      ),
                                      if (isSelected)
                                        Flexible(
                                          child: FadeIn(
                                            child: Text(
                                              mosque.name,
                                                 style: TextStyle(
                          fontFamily: "cairo",
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                                backgroundColor: Colors.white70,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                  if (_isAddingMode)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 40),
                        child: BounceInDown(
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 50),
                        ),
                      ),
                    ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          const SizedBox(height: 70),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: FadeInDown(
                              child: ClipRRect(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        (isDark ? Colors.black : Colors.white)
                                            .withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "نطاق البحث: ${(_searchRadius / 1000).toStringAsFixed(1)} كم",
                                           style: TextStyle(
                          fontFamily: "cairo",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.sp),
                                      ),
                                      Slider(
                                        value: _searchRadius,
                                        activeColor: Colors.green,
                                        min: 1000,
                                        max: 10000,
                                        divisions: 9,
                                        onChanged: (value) => setState(
                                            () => _searchRadius = value),
                                        onChangeEnd: (_) => _fetchMosques(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.32,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          heroTag: "add_mosque",
                          backgroundColor:
                              _isAddingMode ? Colors.red : Colors.green,
                          child: Icon(_isAddingMode
                              ? Icons.close
                              : Icons.add_location_alt),
                          onPressed: () {
                            setState(() {
                              _isAddingMode = !_isAddingMode;
                              if (!_isAddingMode) {
                                _pickedLocation = null;
                              }
                            });
                          },
                        ),
                        if (_isAddingMode) ...[
                          const SizedBox(height: 10),
                          FadeInRight(
                            child: FloatingActionButton.extended(
                              heroTag: "confirm_mosque",
                              backgroundColor: Colors.blue,
                              icon: const Icon(Icons.check),
                              label: Text("تأكيد الموقع",
                                     style: TextStyle(
                          fontFamily: "cairo",)),
                              onPressed: _confirmLocation,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // زر إظهار القائمة عندما تكون مخفية
                  if (!_isAddingMode && !_isBottomSheetVisible)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FadeInUp(
                          child: FloatingActionButton.extended(
                            heroTag: "show_sheet",
                            backgroundColor: Colors.green,
                            icon: const Icon(Icons.keyboard_arrow_up),
                            label: Text(
                              "إظهار المساجد القريبة",
                                 style: TextStyle(
                          fontFamily: "cairo",fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              setState(() {
                                _isBottomSheetVisible = true;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  if (!_isAddingMode && _isBottomSheetVisible)
                    DraggableScrollableSheet(

                      initialChildSize: 0.3,
                      minChildSize: 0.1,
                      maxChildSize: 0.85,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.white,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 12),
                                width: 50,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "المساجد القريبة",
                                         style: TextStyle(
                          fontFamily: "cairo",
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            "${_mosques.length} مسجد",
                                               style: TextStyle(
                          fontFamily: "cairo",
                                                color: Colors.green,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // زر إخفاء القائمة
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _isBottomSheetVisible = false;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (_isLoading)
                                Expanded(
                                    child: Center(
                                        child: KLoading.progressIOSIndicator(
                                            context: context)))
                              else if (_mosques.isEmpty)
                                Expanded(
                                  child: Center(
                                    child: Text("لم يتم العثور على مساجد",
                                           style: TextStyle(
                          fontFamily: "cairo",)),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ListView.builder(
                                    controller: scrollController,
                                    itemCount: _mosques.length,
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context, index) {
                                      final mosque = _mosques[index];
                                      final isSelected =
                                          _selectedMosque?.id == mosque.id;
                                      return FadeInUp(
                                        delay:
                                            Duration(milliseconds: 50 * index),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 6),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (isDark
                                                    ? Colors.green
                                                        .withOpacity(0.2)
                                                    : Colors.green
                                                        .withOpacity(0.05))
                                                : (isDark
                                                    ? Colors.grey[850]
                                                    : Colors.grey[50]),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.green
                                                  : Colors.transparent,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: ListTile(
                                            onTap: () =>
                                                _onMosqueSelected(mosque),
                                            leading: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: (mosque.isUserAdded
                                                        ? Colors.orange
                                                        : Colors.green)
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.mosque,
                                                color: mosque.isUserAdded
                                                    ? Colors.orange
                                                    : Colors.green,
                                              ),
                                            ),
                                            title: Text(
                                              mosque.name,
                                                 style: TextStyle(
                          fontFamily: "cairo",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  mosque.address,
                                                     style: TextStyle(
                          fontFamily: "cairo",
                                                      fontSize: 11.sp,
                                                      color: Colors.grey),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.near_me,
                                                        size: 12,
                                                        color: Colors.blue),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "${mosque.distance.toStringAsFixed(2)} كم",
                                                         style: TextStyle(
                          fontFamily: "cairo",
                                                          fontSize: 11.sp,
                                                          color: Colors.blue),
                                                    ),
                                                    if (mosque.isUserAdded) ...[
                                                      const SizedBox(width: 10),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 6,
                                                                vertical: 1),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.orange
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Text(
                                                            "بواسطة مستخدم",
                                                            style: GoogleFonts
                                                                .cairo(
                                                                    fontSize:
                                                                        9.sp,
                                                                    color: Colors
                                                                        .orange)),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                            trailing: Builder(
                                              builder: (menuContext) {
                                                return Directionality(
                                                  textDirection: TextDirection.rtl,
                                                  child: PopupMenuButton<String>(
                                                    icon: const Icon(Icons.more_vert),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    itemBuilder: (_) => [
                                                      if (mosque.isUserAdded)
                                                        const PopupMenuItem(
                                                          value: 'edit',
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Icon(Icons.edit, color: Colors.orange, size: 18),
                                                              SizedBox(width: 8),
                                                              Text('تعديل',style: TextStyle(fontFamily: "cairo")),
                                                            ],
                                                          ),
                                                        ),
                                                      if (mosque.isUserAdded)
                                                        const PopupMenuItem(
                                                          value: 'delete',
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                                              SizedBox(width: 8),
                                                              Text('حذف',style: TextStyle(fontFamily: "cairo")),
                                                            ],
                                                          ),
                                                        ),
                                                      const PopupMenuItem(
                                                        value: 'directions',
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Icon(Icons.directions, color: Colors.blue, size: 18),
                                                            SizedBox(width: 8),
                                                            Text('الاتجاهات',style: TextStyle(fontFamily: "cairo"),),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                    onSelected: (value) {
                                                      // نأخر التنفيذ Frame واحدة
                                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                                        if (!menuContext.mounted) return;

                                                        switch (value) {
                                                          case 'edit':
                                                            _showEditMosqueDialog(mosque);
                                                            break;
                                                          case 'delete':
                                                            _confirmDelete(mosque);
                                                            break;
                                                          case 'directions':
                                                            _openDirections(mosque);
                                                            break;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                );
                                              },
                                            ),


                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
      ),
    );
  }
}
