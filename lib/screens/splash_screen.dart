import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Trigger the fade-in animation for the logo.
    Future.delayed(Duration.zero, () {
      setState(() {
        _visible = true;
      });
    });
    Future.delayed(
      const Duration(milliseconds: 900),
      () => context.goNamed(AppRoute.home.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 900),
                child: Image.asset(
                  'assets/app_logo.png',
                  width: 96,
                  height: 96,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Citoyenneté France — Quiz & Test',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
