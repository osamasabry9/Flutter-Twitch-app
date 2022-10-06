import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:twitch_clone/app/helper/cache_helper.dart';
import 'package:twitch_clone/app/utils/assets_manager.dart';
import 'package:twitch_clone/app/utils/routes_manager.dart';
import 'package:twitch_clone/app/utils/values_manager.dart';
import 'package:twitch_clone/app/widgets/input_field.dart';
import 'package:twitch_clone/app/widgets/main_button.dart';
import 'package:twitch_clone/app/widgets/show_snack_bar.dart';
import 'package:twitch_clone/features/presentation/auth/cubit/register_cubit/cubit_register.dart';
import 'package:twitch_clone/features/presentation/auth/cubit/register_cubit/states_register.dart';

import '../../../../app/utils/color_manager.dart';

class RegisterScreen extends StatelessWidget {
  TextEditingController emailController = TextEditingController();

  TextEditingController userNameController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  var registerFromKey = GlobalKey<FormState>();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterStates>(
        listener: (context, state) {
          if (state is CreateUserSuccessState) {
            CacheHelper.saveData(
              key: 'uId',
              value: state.uId,
            ).then((value) async {
              showSnackBar(context, 'Welcome in Twitch App');
              Navigator.pushReplacementNamed(context, Routes.mainRoute);
            });
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: registerFromKey,
                      child: Padding(
                        padding: const EdgeInsets.all(AppPadding.p20),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: AppSize.s20),
                              SvgPicture.asset(
                                ImageAssets.welcome,
                                height: AppSize.s100 * 1.5,
                                width: double.infinity,
                              ),
                              const SizedBox(height: AppSize.s40),
                              InputField(
                                textController: emailController,
                                label: "Your email",
                                hint: "Enter your email",
                                prefix: Icons.email,
                                validate: (value) {
                                  if (value!.isEmpty) {
                                    return ' Email address must be filled';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSize.s14),
                              InputField(
                                textController: userNameController,
                                label: "User name",
                                hint: "Enter User name",
                                prefix: Icons.person,
                                validate: (value) {
                                  if (value!.isEmpty) {
                                    return ' User name must be filled';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSize.s14),
                              InputField(
                                textController: passwordController,
                                label: "Password",
                                hint: "Enter password",
                                isPassword:
                                    RegisterCubit.get(context).isPassword,
                                prefix: Icons.lock,
                                suffix: RegisterCubit.get(context).suffix,
                                suffixPressed: () {
                                  RegisterCubit.get(context)
                                      .changePasswordVisibility();
                                },
                                validate: (value) {
                                  if (value!.isEmpty) {
                                    return 'Password must be filled';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSize.s20),
                              MainButton(
                                onTap: () {
                                  RegisterCubit.get(context).userRegister(
                                    username: userNameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                },
                                title: ' Sign Up',
                              ),
                              const SizedBox(height: AppSize.s20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Already have account?  ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacementNamed(
                                            context, Routes.loginRoute);
                                      },
                                      child: Text(
                                        'Login',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                                color: ColorManager.primary),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
