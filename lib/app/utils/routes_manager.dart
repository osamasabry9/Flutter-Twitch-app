import 'package:flutter/material.dart';
import 'package:twitch_clone/app/utils/constants_manager.dart';
import 'package:twitch_clone/features/presentation/auth/screen/login_screen.dart';
import 'package:twitch_clone/features/presentation/auth/screen/register_screen.dart';
import 'package:twitch_clone/features/presentation/home/screen/home_screen.dart';
import 'package:twitch_clone/features/presentation/onboarding/screen/onboarding_screen.dart';
import 'strings_manager.dart';

class Routes {
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgotPassword';
  static const String homeRoute = '/main';
  static const String settings = '/settings';
  static const String editProfile = '/editProfile';
  static const String exploreScreen = '/exploreScreen';
  static const String mapScreen = '/mapScreen';
  static const String hotelScreen = '/hotelScreen';
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.onboardingRoute:
        return MaterialPageRoute(
          builder: (_) => AppConstants.uId == null ? const OnboardingScreen() : const HomeScreen()  ,
        );
        case Routes.loginRoute:
        return MaterialPageRoute(
          builder: (_) =>  LoginScreen(),
        );
        case Routes.registerRoute:
        return MaterialPageRoute(
          builder: (_) =>  RegisterScreen(),
        );
         case Routes.homeRoute:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
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
