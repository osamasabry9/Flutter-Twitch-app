// ignore_for_file: library_prefixes

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twitch_clone/app/helper/app_id.dart';
import 'package:twitch_clone/app/utils/routes_manager.dart';
import 'package:twitch_clone/features/data/model/user_model.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/foundation.dart';
import 'package:twitch_clone/features/presentation/live/cubit/go_live_cubit.dart';
import 'package:twitch_clone/features/presentation/live/widgets/chat_widget.dart';

class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;
  final UserModel userAccount;
  const BroadcastScreen({
    super.key,
    required this.isBroadcaster,
    required this.channelId,
    required this.userAccount,
  });

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final RtcEngine _engine;

  bool isJoined = false, switchCamera = true, switchRender = true;
  List<int> remoteUid = [];
  bool isMuted = false;
  bool isScreenSharing = false;
  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  @override
  void dispose() {
    super.dispose();
    _engine.destroy();
  }

  void _initEngine() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _addListeners();

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      _engine.setClientRole(ClientRole.Audience);
    }
    _joinChannel();
  }
//  Future<void> _initEngine() async {
//     _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
//     _addListeners();

//     await _engine.enableVideo();
//     await _engine.startPreview();
//     await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//     await _engine.setClientRole(ClientRole.Broadcaster);
//   }
  void _addListeners() {
    _engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (channel, uid, elapsed) {
        debugPrint('joinChannelSuccess $channel $uid $elapsed');
      },
      userJoined: (uid, elapsed) {
        debugPrint('userJoined $uid $elapsed');
        setState(() {
          remoteUid.add(uid);
        });
      },
      userOffline: (uid, reason) {
        debugPrint('userOffline $uid $reason');
        setState(() {
          remoteUid.removeWhere((element) => element == uid);
        });
      },
      leaveChannel: (stats) {
        debugPrint('leaveChannel $stats');
        setState(() {
          remoteUid.clear();
        });
      },
    ));
  }
  // void _addListeners() {
  //   _engine.setEventHandler(RtcEngineEventHandler(
  //     warning: (warningCode) {
  //       debugPrint('warning $warningCode');
  //     },
  //     error: (errorCode) {
  //       debugPrint('error $errorCode');
  //     },
  //     joinChannelSuccess: (channel, uid, elapsed) {
  //       debugPrint('joinChannelSuccess $channel $uid $elapsed');
  //       setState(() {
  //         isJoined = true;
  //       });
  //     },
  //     userJoined: (uid, elapsed) {
  //       debugPrint('userJoined  $uid $elapsed');
  //       setState(() {
  //         remoteUid.add(uid);
  //       });
  //     },
  //     userOffline: (uid, reason) {
  //       debugPrint('userOffline  $uid $reason');
  //       setState(() {
  //         remoteUid.removeWhere((element) => element == uid);
  //       });
  //     },
  //     leaveChannel: (stats) {
  //       debugPrint('leaveChannel ${stats.toJson()}');
  //       setState(() {
  //         isJoined = false;
  //         remoteUid.clear();
  //       });
  //     },
  //   ));
  // }

  _joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }

    await _engine.joinChannelWithUserAccount(
        token, 'testing33', widget.userAccount.uId);
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
    if ('${widget.userAccount.uId}${widget.userAccount.username}' ==
        widget.channelId) {
      await GoLiveCubit.get(context).endLiveStream(widget.channelId).then(
            (value) =>
                Navigator.pushReplacementNamed(context, Routes.mainRoute),
          );
    } else {
      await GoLiveCubit.get(context)
          .updateViewCount(widget.channelId, false)
          .then(
            (value) =>
                Navigator.pushReplacementNamed(context, Routes.mainRoute),
          );
    }
  }

  _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      debugPrint('switchCamera $err');
    });
  }

  _onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }

  _switchRender() {
    setState(() {
      switchRender = !switchRender;
      remoteUid = List.of(remoteUid.reversed);
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = widget.userAccount;
    bool isUser = '${user.uId}${user.username}' == widget.channelId;
    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _renderVideo(user),
              if (isUser)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: _switchCamera,
                      child: const Text('Switch Camera'),
                    ),
                    InkWell(
                      onTap: _onToggleMute,
                      child: Text(isMuted ? 'Unmute' : 'Mute'),
                    ),
                  ],
                ),
               Expanded(child: ChatWidget(channelId: widget.channelId, user : user)),
            ],
          ),
        ),
      ),
    );
  }

  _renderVideo(user) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: "${user.uId}${user.username}" == widget.channelId
          ? const RtcLocalView.SurfaceView(
              zOrderMediaOverlay: true,
              zOrderOnTop: true,
            )
          : remoteUid.isNotEmpty
              ? kIsWeb
                  ? RtcRemoteView.SurfaceView(
                      uid: remoteUid[0],
                      channelId: widget.channelId,
                    )
                  : RtcRemoteView.TextureView(
                      uid: remoteUid[0],
                      channelId: widget.channelId,
                    )
              : Container(),
    );
  }
}
