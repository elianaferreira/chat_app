import 'package:chat_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(Dimens.padding),
          width: Dimens.logoSize,
          child: Image.asset('assets/images/chat.png'),
        ),
      ),
    );
  }
}
