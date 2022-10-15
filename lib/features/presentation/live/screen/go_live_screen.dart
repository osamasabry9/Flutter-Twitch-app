import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twitch_clone/app/utils/color_manager.dart';
import 'package:twitch_clone/app/utils/font_manager.dart';
import 'package:twitch_clone/app/utils/routes_manager.dart';
import 'package:twitch_clone/app/utils/styles_manager.dart';
import 'package:twitch_clone/app/utils/values_manager.dart';
import 'package:twitch_clone/app/widgets/input_field.dart';
import 'package:twitch_clone/app/widgets/main_button.dart';
import 'package:twitch_clone/app/widgets/show_snack_bar.dart';
import 'package:twitch_clone/features/presentation/broadcast/broadcast_screen.dart';
import 'package:twitch_clone/features/presentation/live/cubit/go_live_cubit.dart';
import 'package:twitch_clone/features/presentation/live/cubit/go_live_state.dart';
import 'package:twitch_clone/features/presentation/live/widgets/botted_border_widget.dart';

class GoLiveScreen extends StatelessWidget {
  const GoLiveScreen({super.key});
  

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    return BlocConsumer<GoLiveCubit, GoLiveState>(
      listener: (context, state) {
        if (state is GoLiveSuccessState) {
          showSnackBar(context, 'Live stream has started successfully !');
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BroadcastScreen(
              isBroadcaster: true,
              channelId: GoLiveCubit.get(context).channelId,
              userAccount: GoLiveCubit.get(context).userModel!,
            ),
          ));
        } else if (state is GoLiveErrorState) {
          showSnackBar(context, state.error);

          Navigator.pushNamed(context, Routes.mainRoute);
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.p12),
            child: Column(
              children: [
                if (state is GoLiveUploadImageLoadingState)
                  LinearProgressIndicator(
                    color: ColorManager.primary,
                    backgroundColor: ColorManager.primary.withOpacity(0.5),
                  ),
                if (state is GoLiveUploadImageLoadingState)
                  const SizedBox(
                    height: 10,
                  ),
                GestureDetector(
                  onTap: () async {
                    GoLiveCubit.get(context).getPostImage();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p8,
                      vertical: AppPadding.p20,
                    ),
                    child: GoLiveCubit.get(context).postImage != null
                        ? showImageWidget(context)
                        : const BottedBorderWidget(),
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
                  onTap: () {
                    if (GoLiveCubit.get(context).postImage == null) {
                      GoLiveCubit.get(context).createStream(
                        title: titleController.text,
                      );
                    } else {
                      GoLiveCubit.get(context).uploadLiveImage(
                        text: titleController.text,
                      );
                    }
                  },
                  title: 'Go Live!',
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Container showImageWidget(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            4,
          ),
          image: DecorationImage(
            image: FileImage(GoLiveCubit.get(context).postImage!),
            fit: BoxFit.cover,
          )),
    );
  }
}
