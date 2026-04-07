import '../../../core/shard/exports/all_exports.dart';

class AzkarOtherItem extends StatelessWidget {
  final String azkarOtherTitle;
  final String azkarOtherDesc;
  final String azkarRepate;
  final Color? color;
  final double? fontSize;

  const AzkarOtherItem({
    super.key,
    required this.azkarOtherTitle,
    required this.azkarOtherDesc,
    required this.azkarRepate,
    this.color,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return AzkerItemBuilder(
      isOther: true,
      azkarName: "أذكار مختارة",
      // fontFamily: "",
      azkarTitle: azkarOtherTitle,
      azkarDes: azkarOtherDesc,
      fontSize: fontSize,

      azkarRepate: azkarRepate,
      color: color,
    );
  }
}
