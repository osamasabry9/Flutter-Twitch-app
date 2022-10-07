import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:twitch_clone/app/utils/routes_manager.dart';
import 'package:twitch_clone/app/utils/theme_manager.dart';
import 'package:twitch_clone/features/presentation/live/cubit/go_live_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GoLiveCubit()..getUserData(),
      child: ScreenUtilInit(
        minTextAdapt: true,
        splitScreenMode: true,
        designSize: const Size(480, 960),
        builder: (context, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Twitch',
          theme: getApplicationTheme(),
          initialRoute: Routes.onboardingRoute,
          onGenerateRoute: RouteGenerator.getRoute,
        ),
      ),
    );
  }
}
