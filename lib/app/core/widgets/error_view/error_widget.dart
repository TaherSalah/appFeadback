import 'package:flutter/material.dart';

import '../../localization/localization_manager.dart';

class KErrorWidget extends StatelessWidget {
  final void Function()? onTryAgain;
  final String? error;
  final bool? isError;
  final Widget? widget;

  const KErrorWidget(
      {super.key, this.onTryAgain, this.error, this.widget, this.isError = true});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget != null) widget!,
            Text(
              error ?? LocalizationManager.call('try_later'),
              style: isError!
                  ? const TextStyle(color: Colors.red)
                  : const TextStyle(color: Colors.amber),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            if (onTryAgain != null &&
                error !=
                    LocalizationManager.call('location_denaid_permanently'))
              TextButton(
                onPressed: onTryAgain,
                child: Text(LocalizationManager.call('try_again'),
                    style: const TextStyle(color: Color(0xFF629CFF))),
              ),
          ],
        ),
      ),
    );
  }
}
