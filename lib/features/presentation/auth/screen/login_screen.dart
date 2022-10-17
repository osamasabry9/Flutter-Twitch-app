import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:twitch_clone/app/helper/cache_helper.dart';
import 'package:twitch_clone/app/responsive/responsive.dart';
import 'package:twitch_clone/app/utils/assets_manager.dart';
import 'package:twitch_clone/app/utils/routes_manager.dart';
import 'package:twitch_clone/app/utils/values_manager.dart';
import 'package:twitch_clone/app/widgets/input_field.dart';
import 'package:twitch_clone/app/widgets/input_field_label.dart';
import 'package:twitch_clone/app/widgets/main_button.dart';
import 'package:twitch_clone/app/widgets/show_snack_bar.dart';
import 'package:twitch_clone/features/presentation/auth/cubit/login_cubit/cubit_login.dart';
import 'package:twitch_clone/features/presentation/auth/cubit/login_cubit/states_login.dart';

class LoginScreen extends StatelessWidget {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var loginFromKey = GlobalKey<FormState>();
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: BlocConsumer<LoginCubit, LoginStates>(
        listener: (context, state) {
          if (state is LoginErrorState) {
            showSnackBar(context, 'Error login');
          }
          if (state is LoginSuccessState) {
            CacheHelper.saveData(
              key: 'uId',
              value: state.uId,
            ).then((value) async {
              showSnackBar(
                context,
                'Login Success',
              );
              Navigator.pushReplacementNamed(context, Routes.mainRoute);
            });
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Responsive(
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Form(
                        key: loginFromKey,
                        child: Padding(
                          padding: const EdgeInsets.all(AppPadding.p20),
                          child: SingleChildScrollView(
                            child: Column(children: [
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
                                hint: "Enter Your email",
                                prefix: Icons.person,
                                validate: (value) {
                                  if (value!.isEmpty) {
                                    return ' Email Address must be filled';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSize.s14),
                              InputField(
                                textController: passwordController,
                                label: "Password",
                                hint: "Enter password",
                                isPassword: LoginCubit.get(context).isPassword,
                                prefix: Icons.lock,
                                suffix: LoginCubit.get(context).suffix,
                                suffixPressed: () {
                                  LoginCubit.get(context)
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
                              Align(
                                  alignment: AlignmentDirectional.bottomEnd,
                                  child: GestureDetector(
                                      onTap: () {},
                                      child: const InputFieldLabel(
                                          'Forget your Password ?'))),
                              const SizedBox(height: AppSize.s20),
                              MainButton(
                                onTap: () {
                                  LoginCubit.get(context).userLogin(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                },
                                title: ' log in',
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
