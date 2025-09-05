import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/style/k_helper.dart';

class ShimmerBox extends StatelessWidget {
  final double? height, width;

  const ShimmerBox({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.grey.shade200,
      child: Container(
        width: width,
        height: height,
        decoration: KHelper.of(context).shimmerBox,
      ),
    );
  }
}
