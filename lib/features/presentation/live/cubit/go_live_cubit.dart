// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitch_clone/app/utils/constants_manager.dart';
import 'package:twitch_clone/features/data/model/live_stream.dart';
import 'package:twitch_clone/features/data/model/message_model.dart';
import 'package:twitch_clone/features/data/model/user_model.dart';
import 'package:twitch_clone/features/presentation/live/cubit/go_live_state.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:uuid/uuid.dart';

class GoLiveCubit extends Cubit<GoLiveState> {
  GoLiveCubit() : super(GoLiveInitialState());
  static GoLiveCubit get(context) => BlocProvider.of(context);

  UserModel? userModel;
  String channelId = '';

  void getUserData() {
    emit(GetUserLoadingState());
    FirebaseFirestore.instance
        .collection('users')
        .doc(AppConstants.uId!)
        .get()
        .then((value) {
      userModel = UserModel.fromJson(value.data()!);
      emit(GetUserSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(GetUserErrorState(error.toString()));
    });
  }

  final picker = ImagePicker();
  File? postImage;

  Future getPostImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      postImage = File(pickedFile.path);
      emit(GoLiveImagePackerSuccessState());
    } else {
      print('No Image selected');
      emit(GoLiveImagePackerErrorState('No Image selected'));
    }
  }

  void uploadLiveImage({
    required String text,
  }) async {
    emit(GoLiveUploadImageLoadingState());
    if (!((await FirebaseFirestore.instance
            .collection('liveStream')
            .doc('${userModel!.uId}${userModel!.username}')
            .get())
        .exists)) {
      firebase_storage.FirebaseStorage.instance
          .ref()
          .child('liveStream-thumbnail')
          .child(AppConstants.uId!)
          .putFile(postImage!)
          .then((value) {
        value.ref.getDownloadURL().then((value) {
          print(value);
          createStream(title: text, postImage: value);
        }).catchError((onError) {
          emit(GoLiveUploadImageErrorState(onError));
        });
      }).catchError((error) {
        emit(GoLiveUploadImageErrorState(error));
      });
    } else {
      emit(GoLiveErrorState('Two live stream cannot start at the same time.'));
    }
  }

  void createStream({
    required String title,
    String? postImage,
  }) {
    emit(GoLiveLoadingState());
    channelId = '${userModel!.uId}${userModel!.username}';
    LiveStream liveStream = LiveStream(
      title: title,
      image: postImage ?? '',
      uId: AppConstants.uId!,
      username: userModel!.username,
      startedAt: DateTime.now().toString(),
      viewers: 0,
      channelId: channelId,
    );
    FirebaseFirestore.instance
        .collection('liveStream')
        .doc(channelId)
        .set(liveStream.toMap())
        .then((value) {
      emit(GoLiveSuccessState());
      removePostImage();
    }).catchError((error) {
      emit(GoLiveErrorState(error.toString()));
      print(error.toString());
    });
  }

  void removePostImage() {
    postImage = null;
    emit(GoLiveImageRemoveState());
  }

  Future<void> endLiveStream(String channel) async {
    await FirebaseFirestore.instance
        .collection('liveStream')
        .doc(channelId)
        .collection('comments')
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        FirebaseFirestore.instance
            .collection('liveStream')
            .doc(channelId)
            .collection('comments')
            .doc(
              ((value.docs[i].data() as dynamic)['commentId']),
            )
            .delete();
      }
      debugPrint('delete live stream comments ');
    }).catchError((onError) {
      debugPrint(onError.toString());
    });

    await FirebaseFirestore.instance
        .collection('liveStream')
        .doc(channel)
        .delete()
        .then((value) => debugPrint('delete live stream  '))
        .catchError((onError) {
      debugPrint(onError.toString());
    });
  }

  Future<void> updateViewCount(String id, bool isIncrease) async {
    await FirebaseFirestore.instance
        .collection('liveStream')
        .doc(id)
        .update({
          'viewers': FieldValue.increment(isIncrease ? 1 : -1),
        })
        .then((value) => debugPrint('update View Count'))
        .catchError((onError) {
          debugPrint(onError.toString());
        });
  }

  void sendMessage({
    required String id,
    required String text,
  }) {
    String commentId = const Uuid().v1();
    MessageModel model = MessageModel(
      uId: userModel!.uId,
      commentId: commentId,
      message: text,
      username: userModel!.username,
      startedAt: DateTime.now().toString(),
    );

    FirebaseFirestore.instance
        .collection('liveStream')
        .doc(id)
        .collection('comments')
        .doc(commentId)
        .set(model.toMap())
        .then((value) {
      emit(GoLiveSendChatSuccessState());
    }).catchError((onError) {
      emit(GoLiveSendChatErrorState(onError.toString()));
    });
  }

  List<MessageModel> messages = [];
  void getMessage({
    required String id,
  }) {
    emit(GoLiveChatLoadingState());
    FirebaseFirestore.instance
        .collection('liveStream')
        .doc(id)
        .collection('comments')
        .orderBy('startedAt', descending: true)
        .snapshots()
        .listen((event) {
           messages = [];
      event.docs.forEach((element) {
        messages.add(MessageModel.fromJson(element.data()));
      });
      debugPrint("$messages");
      emit(GoLiveChatSuccessState());
    });
  }

}
