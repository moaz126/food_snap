import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:food_snap/core/di/injection_container.dart';
import 'package:food_snap/core/navigation/app_router.dart';
import 'package:food_snap/core/theme/app_theme.dart';
import 'package:food_snap/core/theme/theme_cubit.dart';
import 'package:food_snap/presentation/home/bloc/history_cubit.dart';
import 'package:food_snap/presentation/result_detail/bloc/food_analysis_bloc.dart';

Future<void> main() async {
  // Preserve splash while app initializes
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  const minimumSplashDuration = Duration(seconds: 2);
  final splashTimer = Future<void>.delayed(minimumSplashDuration);

  await dotenv.load(fileName: '.env');
  await configureDependencies();
  await splashTimer;

  // Remove splash after init complete
  FlutterNativeSplash.remove();

  runApp(const FoodSnapApp());
}

class FoodSnapApp extends StatelessWidget {
  const FoodSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<FoodAnalysisBloc>()),
        BlocProvider(create: (_) => sl<HistoryCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'FoodSnap',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
