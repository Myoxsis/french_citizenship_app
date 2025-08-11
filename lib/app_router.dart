import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/results_screen.dart';
import 'screens/review_screen.dart';
import 'screens/settings_screen.dart';

/// Enum of all route names used throughout the app.
enum AppRoute { splash, home, quiz, results, review, settings }

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: AppRoute.splash.name,
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: AppRoute.home.name,
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/quiz',
      name: AppRoute.quiz.name,
      builder: (_, state) =>
          QuizScreen(examMode: state.uri.queryParameters['mode'] == 'exam'),
    ),
    GoRoute(
      path: '/results',
      name: AppRoute.results.name,
      builder: (_, __) => const ResultsScreen(),
    ),
    GoRoute(
      path: '/review',
      name: AppRoute.review.name,
      builder: (_, __) => const ReviewScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: AppRoute.settings.name,
      builder: (_, __) => const SettingsScreen(),
    ),
  ],
);
