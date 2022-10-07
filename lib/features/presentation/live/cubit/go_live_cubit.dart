// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twitch_clone/app/utils/constants_manager.dart';
import 'package:twitch_clone/features/data/model/live_stream.dart';
import 'package:twitch_clone/features/data/model/user_model.dart';
import 'package:twitch_clone/features/presentation/live/cubit/go_live_state.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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
  })async {
    emit(GoLiveUploadImageLoadingState());
    if(!((await FirebaseFirestore.instance
        .collection('liveStream')
        .doc('${userModel!.uId}${userModel!.username}').get()).exists))
   { firebase_storage.FirebaseStorage.instance
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
    });}
    else{
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
}
