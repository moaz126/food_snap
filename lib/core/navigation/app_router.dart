import 'package:flutter/material.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/presentation/home/screens/home_screen.dart';
import 'package:food_snap/presentation/result_detail/screens/result_detail_screen.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = 'home';
  static const String result = 'result';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/result',
        name: AppRoutes.result,
        builder: (context, state) {
          final record = state.extra as FoodRecord;
          return ResultDetailScreen(record: record);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.error}')),
    ),
  );
}
