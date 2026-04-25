import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';
import 'package:food_snap/core/theme/app_palette.dart';
import 'package:food_snap/core/theme/theme_cubit.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = context.appPalette;
    final primary = palette.primary;
    final textSub = palette.textSub;

    return AppBar(
      toolbarHeight: 68,
      centerTitle: false,
      titleSpacing: 0,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'FoodSnap',
                style: AppTextStyles.h2.copyWith(color: primary),
              ),
              Text(
                'Snap a meal, get instant nutrition',
                style: AppTextStyles.caption.copyWith(color: textSub),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.read<ThemeCubit>().toggle(),
          icon: SvgPicture.asset(
            isDark ? 'assets/icons/sun.svg' : 'assets/icons/moon.svg',
            width: 24,
            height: 24,
          ),
        ),
      ],
    );
  }
}
