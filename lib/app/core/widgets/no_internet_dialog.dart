import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:muslimdaily/app/core/widgets/custom_text_widget.dart';
import '../localization/localization_manager.dart';

class NoInternetDialog extends StatefulWidget {
  final VoidCallback onRetrySuccess;

  const NoInternetDialog({super.key, required this.onRetrySuccess});

  @override
  State<NoInternetDialog> createState() => _NoInternetDialogState();
}

class _NoInternetDialogState extends State<NoInternetDialog> {
  bool _isChecking = false;

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
    });

    // Simulate a small delay for better UX (so the user sees something happening)
    await Future.delayed(const Duration(milliseconds: 1000));

    final result = await Connectivity().checkConnectivity();
    if (!mounted) return;

    if (result != ConnectivityResult.none) {
      widget.onRetrySuccess();
    } else {
      setState(() {
        _isChecking = false;
      });
      // Optionally show a small toast or snackbar here if you want
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent dismissing by tapping outside or back
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150.h,
                child: Lottie.asset('assets/json/wifi.json'),
              ),
              SizedBox(height: 16.h),
              TextWidget(
                title: LocalizationManager.call('no_connection'),
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              SizedBox(height: 8.h),
              Text(
                "يرجى التأكد من اتصالك بالإنترنت والمحاولة مرة أخرى",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey,
                  fontFamily: "cairo",
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: _isChecking
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "إعادة المحاولة",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "cairo",
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
}
