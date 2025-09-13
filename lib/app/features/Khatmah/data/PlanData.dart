class PlanData {
  final int days;
  final int currentDayIndex; // 0-based
  final List<List<int>> plan;
  PlanData(
      {required this.days, required this.currentDayIndex, required this.plan});
}
