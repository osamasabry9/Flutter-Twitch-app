import 'package:flutter/material.dart';
import 'package:twitch_clone/app/utils/assets_manager.dart';
import 'package:twitch_clone/app/utils/color_manager.dart';
import 'package:twitch_clone/app/utils/routes_manager.dart';
import 'package:twitch_clone/app/utils/values_manager.dart';
import 'package:twitch_clone/app/widgets/main_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.p40,
            vertical: AppPadding.p60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: AppSize.s30,
              ),
              Center(
                child: Image.asset(
                  ImageAssets.icon,
                  height: size.height * 0.3,
                  width: size.width * 0.5,
                  fit: BoxFit.cover,
                ),
              ),
              const Spacer(),
              MainButton(
                onTap: () {
                  Navigator.pushNamed(context, Routes.loginRoute);
                },
                title: 'Log in',
              ),
              const SizedBox(
                height: AppSize.s18,
              ),
              MainButton(
                onTap: () {
                  Navigator.pushNamed(context, Routes.registerRoute);
                },
                title: 'Sign Up',
                color: ColorManager.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
