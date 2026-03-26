import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muslimdaily/app/core/shard/exports/all_exports.dart';
import 'package:muslimdaily/app/features/quranView/view/widget/QuranViewItemBuilder.dart';

class QuranView extends StatelessWidget {
  final int? initialPage;
  final VoidCallback? onConfirm;
  final String? campaignId; // ID of the Khatmah campaign
  final int? targetPage; // End page of the current ورد

  const QuranView({
    super.key,
    this.initialPage,
    this.onConfirm,
    this.campaignId,
    this.targetPage,
  });

  @override
  Widget build(BuildContext context) {
    return QuranViewItemBuilder(
      initialPage: initialPage,
      onConfirm: onConfirm,
      campaignId: campaignId,
      targetPage: targetPage,
    );
  }
}
