import 'package:flutter/material.dart';

import '../../utils/constent/styles_manager.dart';
import '../../utils/style/k_color.dart';

class KErrorView extends StatelessWidget {
  final void Function()? onTryAgain;
  final String? error;

  const KErrorView({super.key, this.onTryAgain, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error ?? 'Tr.get.try_later',
              style: getLigthStyle(color: KColors.accentColor),
            ),
            //Lottie.asset('assets/animations/error.json'),
            const SizedBox(height: 25),
            if (onTryAgain != null)
              TextButton(
                onPressed: onTryAgain,
                child: Text('try again',
                    style: getLigthStyle(color: KColors.accentColor)),
              ),
          ],
        ),
      ),
    );
  }
}
