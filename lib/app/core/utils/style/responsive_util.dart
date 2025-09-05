import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveUtil {
  // Define breakpoints
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  // Responsive text size
  static double textSize(BuildContext context, double mobileSize,
      [double? tabletSize]) {
    return isTablet(context) ? tabletSize?.sp ?? mobileSize.sp : mobileSize.sp;
  }

  // Responsive padding
  static EdgeInsetsGeometry padding(BuildContext context, double mobilePadding,
      [double? tabletPadding]) {
    double horizontalPadding = isTablet(context)
        ? tabletPadding?.w ?? mobilePadding.w
        : mobilePadding.w;
    double verticalPadding = isTablet(context)
        ? tabletPadding?.h ?? mobilePadding.h
        : mobilePadding.h;
    return EdgeInsets.symmetric(
        horizontal: horizontalPadding, vertical: verticalPadding);
  }

  // Responsive button style
  static ButtonStyle buttonStyle(BuildContext context, Color color) {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet(context) ? 30.w : 15.w,
        vertical: isTablet(context) ? 20.h : 10.h,
      ),
      textStyle: TextStyle(
        fontSize: textSize(context, 14, 16),
      ),
      backgroundColor: color,
    );
  }
}

// class ResponsiveExample extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Create an instance of the Responsive class
//     final responsive = Responsive(context);
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Responsive Example')),
//       body: Center(
//         child: Padding(
//           padding: responsive.responsivePadding(20, 10, 20, 10),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: responsive.responsiveWidth(200),
//                 height: responsive.responsiveHeight(100),
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   borderRadius: responsive.responsiveBorderRadius(15),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Responsive Container',
//                     style:
//                         TextStyle(fontSize: responsive.responsiveFontSize(20)),
//                   ),
//                 ),
//               ),
//               SizedBox(height: responsive.responsiveHeight(20)),
//               Text(
//                 'This is a ${responsive.isMobile ? "Mobile" : responsive.isTablet ? "Tablet" : "Desktop"} view.',
//                 style: TextStyle(fontSize: responsive.responsiveFontSize(16)),
//               ),
//               SizedBox(height: responsive.responsiveHeight(20)),
//               // Example of using aspect ratio
//               Container(
//                 width: responsive.responsiveAspectRatio(16 / 9).width,
//                 height: responsive.responsiveAspectRatio(16 / 9).height,
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   borderRadius: responsive.responsiveBorderRadius(10),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '16:9 Aspect Ratio',
//                     style:
//                         TextStyle(fontSize: responsive.responsiveFontSize(18)),
//                   ),
//                 ),
//               ),
//               SizedBox(height: responsive.responsiveHeight(20)),
//               Container(
//                 margin: responsive.responsiveMargin(10, 20, 10, 20),
//                 padding: responsive.responsivePadding(15, 10, 15, 10),
//                 color: Colors.red,
//                 child: Text(
//                   'Responsive Margin and Padding',
//                   style: TextStyle(fontSize: responsive.responsiveFontSize(18)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class ResponsiveExample extends StatelessWidget {
  const ResponsiveExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Create an instance of the Responsive class
    final responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Example')),
      body: Center(
        child: Padding(
          padding: responsive.responsivePadding(20, 10, 20, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: responsive.responsiveWidth(200),
                height: responsive.responsiveHeight(100),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: responsive.responsiveBorderRadius(15),
                ),
                child: Center(
                  child: Text(
                    'Responsive Container',
                    style: TextStyle(
                      fontSize: responsive.responsiveFontSize(20),
                      fontWeight:
                          responsive.getFontWeight('bold'), // Using font weight
                    ),
                  ),
                ),
              ),
              SizedBox(height: responsive.responsiveHeight(20)),
              Text(
                'This is a ${responsive.isMobile ? "Mobile" : responsive.isTablet ? "Tablet" : "Desktop"} view.',
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(16),
                  fontWeight:
                      responsive.getFontWeight('regular'), // Using font weight
                ),
              ),
              SizedBox(height: responsive.responsiveHeight(20)),
              // Example of using aspect ratio
              Container(
                width: responsive.responsiveAspectRatio(16 / 9).width,
                height: responsive.responsiveAspectRatio(16 / 9).height,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: responsive.responsiveBorderRadius(10),
                ),
                child: Center(
                  child: Text(
                    '16:9 Aspect Ratio',
                    style: TextStyle(
                      fontSize: responsive.responsiveFontSize(18),
                      fontWeight: responsive
                          .getFontWeight('semibold'), // Using font weight
                    ),
                  ),
                ),
              ),
              SizedBox(height: responsive.responsiveHeight(20)),
              Container(
                margin: responsive.responsiveMargin(10, 20, 10, 20),
                padding: responsive.responsivePadding(15, 10, 15, 10),
                color: Colors.red,
                child: Text(
                  'Responsive Margin and Padding',
                  style: TextStyle(
                    fontSize: responsive.responsiveFontSize(18),
                    fontWeight:
                        responsive.getFontWeight('medium'), // Using font weight
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

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  // Get the screen width
  double get width => MediaQuery.of(context).size.width;

  // Get the screen height
  double get height => MediaQuery.of(context).size.height;

  // Get the aspect ratio
  double get aspectRatio => width / height;

  // Get the text scaling factor
  double get textScaleFactor => MediaQuery.of(context).textScaleFactor;

  // Check if the device is mobile
  bool get isMobile => width < 600;

  // Check if the device is tablet
  bool get isTablet => width >= 600 && width < 1200;

  // Check if the device is desktop
  bool get isDesktop => width >= 1200;

  // Get responsive height
  double responsiveHeight(double inputHeight) {
    return (inputHeight / 812) *
        height; // 812 is the height of the iPhone 11 Pro
  }

  // Get responsive width
  double responsiveWidth(double inputWidth) {
    return (inputWidth / 375) * width; // 375 is the width of the iPhone 11 Pro
  }

  // Get responsive font size
  double responsiveFontSize(double inputFontSize) {
    return (inputFontSize / 16) *
        (textScaleFactor * 16); // 16 is a standard base font size
  }

  // Get responsive padding
  EdgeInsets responsivePadding(
      double left, double top, double right, double bottom) {
    return EdgeInsets.fromLTRB(
      responsiveWidth(left),
      responsiveHeight(top),
      responsiveWidth(right),
      responsiveHeight(bottom),
    );
  }

  // Get responsive margin
  EdgeInsets responsiveMargin(
      double left, double top, double right, double bottom) {
    return EdgeInsets.fromLTRB(
      responsiveWidth(left),
      responsiveHeight(top),
      responsiveWidth(right),
      responsiveHeight(bottom),
    );
  }

  // Get responsive border radius
  BorderRadius responsiveBorderRadius(double radius) {
    return BorderRadius.circular(responsiveWidth(radius));
  }

  // Get responsive dimensions based on aspect ratio
  Size responsiveAspectRatio(double aspectRatio) {
    double newWidth = width;
    double newHeight = newWidth / aspectRatio;

    // If the calculated height exceeds the screen height, adjust width accordingly
    if (newHeight > height) {
      newHeight = height;
      newWidth = newHeight * aspectRatio;
    }

    return Size(newWidth, newHeight);
  }

  // Get font weight based on design requirements
  FontWeight getFontWeight(String weight) {
    switch (weight.toLowerCase()) {
      case 'light':
        return FontWeight.w300;
      case 'regular':
        return FontWeight.w400;
      case 'medium':
        return FontWeight.w500;
      case 'semibold':
        return FontWeight.w600;
      case 'bold':
        return FontWeight.w700;
      case 'extrabold':
        return FontWeight.w800;
      case 'black':
        return FontWeight.w900;
      default:
        return FontWeight.normal; // Default to regular
    }
  }
}
