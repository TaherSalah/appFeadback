import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/MosqueModel.dart';
import 'services/MosqueService.dart';

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

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Fluttertoast.showToast(msg: "يرجى تفعيل خدمة الموقع");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: "تم رفض إذن الموقع");
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
      print('Location Error: $e');
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

      Fluttertoast.showToast(msg: "تم العثور على ${mosques.length} مسجد");
    }
  }

  void _onMosqueSelected(Mosque mosque) {
    setState(() {
      _selectedMosque = mosque;
    });

    // Animate to mosque location
    _mapController.move(
      LatLng(mosque.latitude, mosque.longitude),
      15,
    );
  }

  void _openDirections(Mosque mosque) async {
    final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
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
            "المساجد القريبة",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                if (_userPosition != null) {
                  _mapController.move(
                    LatLng(_userPosition!.latitude, _userPosition!.longitude),
                    14,
                  );
                }
              },
            ),
          ],
        ),
        body: _userPosition == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Map
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                          _userPosition!.latitude, _userPosition!.longitude),
                      initialZoom: 14,
                      minZoom: 10,
                      maxZoom: 18,
                    ),
                    children: [
                      // OpenStreetMap Tiles
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.rafiq.muslimdaily',
                      ),

                      // Markers
                      MarkerLayer(
                        markers: [
                          // User location marker
                          Marker(
                            point: LatLng(_userPosition!.latitude,
                                _userPosition!.longitude),
                            width: 60,
                            height: 60,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 40,
                            ),
                          ),

                          // Mosque markers
                          ..._mosques.map((mosque) {
                            final isSelected = _selectedMosque?.id == mosque.id;
                            return Marker(
                              point: LatLng(mosque.latitude, mosque.longitude),
                              width: isSelected ? 80 : 60,
                              height: isSelected ? 80 : 60,
                              child: GestureDetector(
                                onTap: () => _onMosqueSelected(mosque),
                                child: Icon(
                                  Icons.mosque,
                                  color:
                                      isSelected ? Colors.amber : Colors.green,
                                  size: isSelected ? 50 : 40,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),

                  // Search Radius Slider
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "نطاق البحث: ${(_searchRadius / 1000).toStringAsFixed(1)} كم",
                            style:
                                GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          Slider(
                            value: _searchRadius,
                            min: 1000,
                            max: 10000,
                            divisions: 9,
                            label:
                                "${(_searchRadius / 1000).toStringAsFixed(0)} كم",
                            onChanged: (value) {
                              setState(() {
                                _searchRadius = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _fetchMosques();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Sheet - Mosque List
                  DraggableScrollableSheet(
                    initialChildSize: 0.3,
                    minChildSize: 0.15,
                    maxChildSize: 0.7,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 10),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Handle bar
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),

                            // Title
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "المساجد القريبة (${_mosques.length})",
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (_isLoading)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                ],
                              ),
                            ),

                            const Divider(),

                            // Mosque List
                            Expanded(
                              child: _mosques.isEmpty
                                  ? Center(
                                      child: Text(
                                        "لم يتم العثور على مساجد",
                                        style: GoogleFonts.cairo(fontSize: 16),
                                      ),
                                    )
                                  : ListView.builder(
                                      controller: scrollController,
                                      itemCount: _mosques.length,
                                      itemBuilder: (context, index) {
                                        final mosque = _mosques[index];
                                        final isSelected =
                                            _selectedMosque?.id == mosque.id;

                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? (isDark
                                                    ? Colors.green[900]
                                                    : Colors.green[50])
                                                : (isDark
                                                    ? Colors.grey[850]
                                                    : Colors.grey[100]),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.green
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: ListTile(
                                            leading: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.mosque,
                                                  color: Colors.green),
                                            ),
                                            title: Text(
                                              mosque.name,
                                              style: GoogleFonts.cairo(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (mosque.address.isNotEmpty)
                                                  Text(
                                                    mosque.address,
                                                    style: GoogleFonts.cairo(
                                                        fontSize: 12),
                                                  ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.location_on,
                                                        size: 14,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "${mosque.distance.toStringAsFixed(2)} كم",
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.directions,
                                                  color: Colors.blue),
                                              onPressed: () =>
                                                  _openDirections(mosque),
                                            ),
                                            onTap: () =>
                                                _onMosqueSelected(mosque),
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
