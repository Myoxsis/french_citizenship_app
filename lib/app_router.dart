import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/results_screen.dart';
import 'screens/review_screen.dart';
import 'screens/settings_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/quiz',
      builder: (_, state) =>
          QuizScreen(examMode: state.uri.queryParameters['mode'] == 'exam'),
    ),
    GoRoute(path: '/results', builder: (_, __) => const ResultsScreen()),
    GoRoute(path: '/review', builder: (_, __) => const ReviewScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);
