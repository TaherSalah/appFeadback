
import 'dart:math' as math;
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/widgets/KLoading.dart';



class ARQiblaCameraWidget extends StatefulWidget {
  final double qiblaDirection; // Qibla angle (e.g., 130 degrees)
  final double heading;        // Current phone heading
  final bool isActive;
  
  const ARQiblaCameraWidget({
    super.key,
    required this.qiblaDirection,
    required this.heading,
    this.isActive = true,
  });

  @override
  State<ARQiblaCameraWidget> createState() => _ARQiblaCameraWidgetState();
}

class _ARQiblaCameraWidgetState extends State<ARQiblaCameraWidget> with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  String _errorMsg = "";
  
  late AnimationController _pulseController;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initCamera();
    }
    
    // Pulse animation for the Kaaba icon
    _pulseController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Radar rotation animation
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void didUpdateWidget(ARQiblaCameraWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _initCamera();
      } else {
        _controller?.dispose();
        _controller = null;
        if (mounted) {
          setState(() {
            _isCameraInitialized = false;
          });
        }
      }
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0], 
          ResolutionPreset.high, // Higher quality
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        setState(() {
          _errorMsg = "No camera available";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = "Camera Error: $e";
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pulseController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMsg.isNotEmpty) {
      return Center(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(20),
          child: Text(
            "Error: $_errorMsg",
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _controller == null) {
      return  Center(child:  KLoading.progressIOSIndicator(context: context));
    }

    // Calculations
    double diff = widget.qiblaDirection - widget.heading;
    diff = (diff + 180) % 360 - 180;

    final screenWidth = MediaQuery.of(context).size.width;
    const double fov = 60.0; 
    double horizontalOffset = (diff / fov) * screenWidth;
    bool isInView = diff.abs() < (fov / 2);
    
    // Check alignment for haptic/visual feedback (tolerance 5 degrees)
    bool isAligned = diff.abs() < 5;

    return Stack(
      children: [
        // 1. Camera Feed
        SizedBox.expand(
          child: CameraPreview(_controller!),
        ),

        // 2. Gradient Overlay (for better text visibility)
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black45, Colors.transparent, Colors.black45],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.4, 0.8],
              ),
            ),
          ),
        ),

        // 3. Radar / Compass HUD
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                "${widget.heading.toStringAsFixed(0)}°",
                style: GoogleFonts.bebasNeue(
                  fontSize: 40.sp, 
                  color: isAligned ? Colors.greenAccent : Colors.white,
                  shadows: [const Shadow(blurRadius: 10, color: Colors.blueAccent)]
                ),
              ),
              const SizedBox(height: 10),
              // Radar Design
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2),
                  color: Colors.black26,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sweeping radar
                    RotationTransition(
                      turns: _radarController,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [Colors.green.withOpacity(0.0), Colors.green.withOpacity(0.5)],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Small dot representing User
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    // Direction Dot representing Qibla on Radar
                    Transform.translate(
                        offset: Offset(
                           18 * math.sin(diff * (math.pi / 180)), 
                          -18 * math.cos(diff * (math.pi / 180))
                        ),
                        child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),

        // 4. Floating Kaaba Overlay
        if (isInView)
          Positioned(
            left: (screenWidth / 2) + horizontalOffset - 60, // Centered
            top: MediaQuery.of(context).size.height * 0.4, // Slightly above center
            child: Column(
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.1).animate(_pulseController),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      boxShadow: [
                         BoxShadow(
                           color: isAligned ? Colors.greenAccent.withOpacity(0.6) : Colors.amber.withOpacity(0.2),
                           blurRadius: 20,
                           spreadRadius: 5
                         )
                      ]
                    ),
                    child: Image.asset(
                      "assets/images/kaaba.png", 
                      width: 120,
                      height: 120,
                      errorBuilder: (_,__,___) => const Icon(Icons.mosque, size: 100, color: Colors.white),
                    ),
                  ),
                ),
                if (isAligned)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      "القبلة هنا ✨",
                      style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
              ],
            ),
          )
        else 
          // 5. Off-screen Indicators
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: diff > 0 ? null : 20,
            right: diff > 0 ? 20 : null,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.2).animate(_pulseController),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 10)
                  ]
                ),
                child: Icon(
                  diff > 0 ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          
        // 6. Bottom Info Panel
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                         const Icon(Icons.share_location, color: Colors.white70),
                         const SizedBox(height: 5),
                         Text("المسافة", style: GoogleFonts.cairo(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                    Container(width: 1, height: 30, color: Colors.white12),
                    Text(
                         isAligned ? "أنت تواجه القبلة" : "ابحث عن الكعبة",
                         style: GoogleFonts.cairo(
                           color: isAligned ? Colors.greenAccent : Colors.white, 
                           fontWeight: FontWeight.bold,
                           fontSize: 16
                         ),
                    ),
                     Container(width: 1, height: 30, color: Colors.white12),
                     Column(
                      children: [
                         const Icon(Icons.compass_calibration, color: Colors.white70),
                         const SizedBox(height: 5),
                         Text("الدقة عالية", style: GoogleFonts.cairo(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
