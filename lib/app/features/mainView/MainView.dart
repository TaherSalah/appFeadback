import 'package:muslimdaily/app/features/mainView/widget/HomeScreenBuilder.dart';
import '../../core/shard/exports/all_exports.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    return const MainViewBuilder();
  }
}
