import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:twitch_clone/app/utils/color_manager.dart';
import 'package:twitch_clone/app/utils/font_manager.dart';
import 'package:twitch_clone/app/utils/styles_manager.dart';
import 'package:twitch_clone/app/utils/values_manager.dart';
import 'package:twitch_clone/app/widgets/input_field.dart';
import 'package:twitch_clone/app/widgets/main_button.dart';
import 'package:twitch_clone/app/widgets/pick_image.dart';

class GoLiveScreen extends StatefulWidget {
  const GoLiveScreen({super.key});

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    Uint8List? image;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.p12),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                Uint8List? pickedImage = await pickImage();
                if (pickedImage != null) {
                  setState(() {
                    image = pickedImage;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p8,
                  vertical: AppPadding.p20,
                ),
                child: image != null
                    ? SizedBox(
                        height: AppSize.s150,
                        child: Image.memory(image),
                      )
                    : DottedBorder(
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(AppSize.s12),
                        dashPattern: const [10, 4],
                        strokeCap: StrokeCap.round,
                        color: ColorManager.primary,
                        child: Container(
                          height: AppSize.s150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSize.s12),
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
                      ),
              ),
            ),
            const SizedBox(height: AppSize.s12),
            InputField(
              label: 'Title',
              textController: titleController,
              style: getMediumStyle(
                  color: ColorManager.grey, fontSize: FontSize.s20),
              validate: (value) {
                return null;
              },
            ),
            const Spacer(),
            MainButton(
              onTap: () {},
              title: 'Go Live!',
            )
          ],
        ),
      ),
    );
  }
}
