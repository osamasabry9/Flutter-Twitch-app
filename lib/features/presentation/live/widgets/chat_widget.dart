import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twitch_clone/app/utils/color_manager.dart';
import 'package:twitch_clone/app/utils/font_manager.dart';
import 'package:twitch_clone/app/utils/styles_manager.dart';
import 'package:twitch_clone/app/widgets/input_field.dart';
import 'package:twitch_clone/features/data/model/user_model.dart';
import 'package:twitch_clone/features/presentation/live/cubit/go_live_cubit.dart';
import 'package:twitch_clone/features/presentation/live/cubit/go_live_state.dart';

class ChatWidget extends StatefulWidget {
  final String channelId;
  final UserModel user;
  const ChatWidget({super.key, required this.channelId, required this.user});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoLiveCubit, GoLiveState>(
      builder: (context, state) {
        GoLiveCubit.get(context).getMessage(id: widget.channelId);
        final size = MediaQuery.of(context).size;
        return SizedBox(
          width: size.width > 600 ? size.width * 0.25 : double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (widget.user.uId !=
                        GoLiveCubit.get(context).messages[index].uId) {
                      return buildMessage(
                        alignment: AlignmentDirectional.centerEnd,
                        bottomEnd: 0.0,
                        bottomStart: 10.0,
                        color: ColorManager.grey,
                        message:
                            GoLiveCubit.get(context).messages[index].message,
                        userName:
                            GoLiveCubit.get(context).messages[index].username,
                      );
                    } else {
                      return buildMessage(
                        alignment: AlignmentDirectional.centerStart,
                        bottomEnd: 10.0,
                        bottomStart: 0.0,
                        color: ColorManager.primary,
                        message:
                            GoLiveCubit.get(context).messages[index].message,
                        userName:
                            GoLiveCubit.get(context).messages[index].username,
                      );
                    }
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 15.0,
                  ),
                  itemCount: GoLiveCubit.get(context).messages.length,
                ),
              ),
              InputField(
                textController: textController,
                style: getMediumStyle(
                    color: ColorManager.grey, fontSize: FontSize.s16),
                validate: (value) {
                  return null;
                },
                onFieldSubmitted: (p0) {
                  GoLiveCubit.get(context).sendMessage(
                    id: widget.channelId,
                    text: textController.text,
                  );
                  setState(() {
                    textController.text = '';
                  });
                  return null;
                },
                label: 'Chat ',
              ),
            ],
          ),
        );
      },
    );
  }

  Align buildMessage({
    required AlignmentGeometry alignment,
    required double bottomEnd,
    required double bottomStart,
    required Color color,
    required String message,
    required String userName,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(bottomEnd),
            bottomStart: Radius.circular(bottomStart),
            topEnd: const Radius.circular(10.0),
            topStart: const Radius.circular(10.0),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              userName,
              style: getMediumStyle(
                  color: ColorManager.white, fontSize: FontSize.s16),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(message),
          ],
        ),
      ),
    );
  }
}
