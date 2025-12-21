import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/shard/widgets/about_item_builder.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: CupertinoNavigationBarBackButton(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        body: const SingleChildScrollView(
            physics: BouncingScrollPhysics(), child: AboutItemBuilder()),
      ),
    );
  }
}
