import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:twitch_clone/app/utils/color_manager.dart';
import 'package:twitch_clone/app/utils/font_manager.dart';
import 'package:twitch_clone/app/utils/styles_manager.dart';
import 'package:twitch_clone/app/utils/values_manager.dart';


class BottedBorderWidget extends StatelessWidget {
  const BottedBorderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(AppSize.s12),
                          dashPattern: const [10, 4],
                          strokeCap: StrokeCap.round,
                          color: ColorManager.primary,
                          child: Container(
                            height: AppSize.s150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppSize.s12),
                              color: ColorManager.primary.withOpacity(0.05),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.folder_open,
                                  size: AppSize.s40,
                                  color: ColorManager.primary,
                                ),
                                const SizedBox(height: AppSize.s12),
                                Text(
                                  'Select your thumbnail',
                                  style: getMediumStyle(
                                      color: ColorManager.grey,
                                      fontSize: FontSize.s18),
                                ),
                              ],
                            ),
                          ),
                        );
  }
}