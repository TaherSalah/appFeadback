import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:muslimdaily/app/core/widgets/shimmer_box.dart';

import '../utils/style/k_helper.dart';


String get dummyNetImg =>
    "http://api.yaqees.com/yaqees/public/uploads/clients/default.png";

String get dummyAssetImg => "assets/image/homeslider.png";

class KImageWidget extends StatelessWidget {
  const KImageWidget(
      {super.key,
      required this.imageUrl,
      this.width,
      this.height = 200,
      this.color,
      this.placeHolder,
      this.errorBuilder,
      this.fit,
      this.overrideColor = true});
  final String imageUrl;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit? fit;
  final Widget? placeHolder;
  final Widget? errorBuilder;
  final bool overrideColor;

  @override
  Widget build(BuildContext context) {
    return
        //   imageUrl.endsWith('.svg')
        //     ? CachedSvgImage(
        //   url: imageUrl,
        //   color: color,
        //   height: height,
        //   fit: fit,
        //   width: width,
        //   overrideColor: overrideColor,
        //   placeHolder: ShimmerBox(height: height, width: width),
        //   errorBuilder: KImageWidget(imageUrl: dummyNetImg),
        // )
        //     :
        CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      color: color,
      fit: fit,
      placeholder: (context, url) {
        return ShimmerBox(height: height, width: width);
      },
      errorWidget: (context, url, error) {
        return KImageWidget(imageUrl: dummyNetImg);
      },
      imageBuilder: (BuildContext context, ImageProvider imageProvider) =>
          Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(KHelper.btnRadius),
          image: DecorationImage(
            image: imageProvider,
            fit: fit ?? BoxFit.fill,
          ),
        ),
      ),
      width: width,
    );
  }
}

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:yaqess/core/utils/k_helper.dart';
// import 'package:yaqess/core/widgets/shimmer_box.dart';
//
// String get dummyNetImg => "http://api.yaqees.com/yaqees/public/uploads/clients/default.png";
// String get dummyAssetImg => "assets/image/homeslider.png";
//
// class KImageWidget extends StatelessWidget {
//   const KImageWidget({
//     Key? key,
//     required this.imageUrl,
//     this.width,
//     this.height = 200.0, // Default height value
//     this.color,
//     this.placeHolder,
//     this.errorBuilder,
//     this.fit,
//     this.overrideColor = true
//   }) : super(key: key);
//
//   final String imageUrl;
//   final double? width;
//   final double? height;
//   final Color? color;
//   final BoxFit? fit;
//   final Widget? placeHolder;
//   final Widget? errorBuilder;
//   final bool overrideColor;
//
//   @override
//   Widget build(BuildContext context) {
//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       height: height,
//       color: color,
//       fit: fit,
//       placeholder: (context, url) {
//         return ShimmerBox(height: height, width: width);
//       },
//       errorWidget: (context, url, error) {
//         return KImageWidget(imageUrl: dummyNetImg, height: height, width: width);
//       },
//       imageBuilder: (BuildContext context, ImageProvider imageProvider) =>
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.rectangle,
//               borderRadius: BorderRadius.circular(KHelper.btnRadius),
//               image: DecorationImage(
//                 image: imageProvider,
//                 fit: BoxFit.fill,
//               ),
//             ),
//           ),
//       width: width,
//     );
//   }
// }
