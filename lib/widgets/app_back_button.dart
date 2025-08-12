import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_router.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BackButton(
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          context.pop();
        } else {
          context.goNamed(AppRoute.home.name);
        }
      },
    );
  }
}
