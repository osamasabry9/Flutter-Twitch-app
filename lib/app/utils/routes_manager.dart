import 'package:flutter/material.dart';
import 'package:twitch_clone/app/utils/constants_manager.dart';
import 'package:twitch_clone/features/presentation/auth/screen/login_screen.dart';
import 'package:twitch_clone/features/presentation/auth/screen/register_screen.dart';
import 'package:twitch_clone/features/presentation/browser/screen/browser_screen.dart';
import 'package:twitch_clone/features/presentation/home/screen/home_screen.dart';
import 'package:twitch_clone/features/presentation/home/screen/main_screen.dart';
import 'package:twitch_clone/features/presentation/live/screen/go_live_screen.dart';
import 'package:twitch_clone/features/presentation/onboarding/screen/onboarding_screen.dart';
import 'strings_manager.dart';

class Routes {
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String mainRoute = '/main';
  static const String homeRoute = '/home';
  static const String goLiveRoute = '/goLive';
  static const String browserRoute = '/browser';

}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.onboardingRoute:
        return MaterialPageRoute(
          builder: (_) => AppConstants.uId == null ? const OnboardingScreen() : const MainScreen()  ,
        );
        case Routes.loginRoute:
        return MaterialPageRoute(
          builder: (_) =>  LoginScreen(),
        );
        case Routes.registerRoute:
        return MaterialPageRoute(
          builder: (_) =>  RegisterScreen(),
        );
         case Routes.mainRoute:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
        );
         case Routes.homeRoute:
        return MaterialPageRoute(
          builder: (_) =>  const HomeScreen(),
        );
        case Routes.goLiveRoute:
        return MaterialPageRoute(
          builder: (_) =>  const GoLiveScreen(),
        );
         case Routes.browserRoute:
        return MaterialPageRoute(
          builder: (_) => const BrowserScreen(),
        );
     
      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.onRouteFound),
        ),
        body: const Center(child: Text(AppStrings.onRouteFound)),
      ),
    );
  }
}
