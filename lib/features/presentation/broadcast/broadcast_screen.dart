// ignore_for_file: library_prefixes

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twitch_clone/app/helper/app_id.dart';
import 'package:twitch_clone/app/responsive/responsive_layout.dart';
import 'package:twitch_clone/app/utils/color_manager.dart';
import 'package:twitch_clone/app/utils/routes_manager.dart';
import 'package:twitch_clone/app/widgets/main_button.dart';
import 'package:twitch_clone/features/data/model/user_model.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/foundation.dart';
import 'package:twitch_clone/features/presentation/live/cubit/go_live_cubit.dart';
import 'package:twitch_clone/features/presentation/live/widgets/chat_widget.dart';
import 'package:http/http.dart' as http;

class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;

  const BroadcastScreen({
    super.key,
    required this.isBroadcaster,
    required this.channelId,
  });

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late final UserModel userAccount;
  late final RtcEngine _engine;

  bool isJoined = false, switchCamera = true, switchRender = true;
  List<int> remoteUid = [];
  bool isMuted = false;
  bool isScreenSharing = false;
  @override
  void initState() {
    userAccount = GoLiveCubit.get(context).userModel!;
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

//https://twitch-server-clone.herokuapp.com/rtc/testing33/publisher/userAccount/u2gIO0D4V5fdKm0ZvVvjRKsvScQ2/
  String baseUrl = "https://twitch-server-clone.herokuapp.com";
  String? tokenGen;
  Future<void> getToken() async {
    final res = await http.get(
      Uri.parse(
          "$baseUrl/rtc/${widget.channelId}/publisher/userAccount/${userAccount.uId}/"),
    );

    if (res.statusCode == 200) {
      setState(() {
        tokenGen = res.body;
        tokenGen = jsonDecode(tokenGen!)['rtcToken'];
      });
    } else {
      debugPrint('Failed to fetch the token');
    }
  }

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
      tokenPrivilegeWillExpire: (token) async {
        await getToken();
        await _engine.renewToken(token);
      },
    ));
  }

  _joinChannel() async {
    await getToken();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }

    await _engine.joinChannelWithUserAccount(
        tokenGen, 'testing33', userAccount.uId);
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
    if ('${userAccount.uId}${userAccount.username}' == widget.channelId) {
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

  _startScreenShare() async {
    final helper = await _engine.getScreenShareHelper(
        appGroup: kIsWeb || Platform.isWindows ? null : 'io.agora');
    await helper.disableAudio();
    await helper.enableVideo();
    await helper.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await helper.setClientRole(ClientRole.Broadcaster);
    var windowId = 0;
    var random = Random();
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isAndroid)) {
      final windows = _engine.enumerateWindows();
      if (windows.isNotEmpty) {
        final index = random.nextInt(windows.length - 1);
        debugPrint('Screen sharing window with index $index');
        windowId = windows[index].id;
      }
    }
    await helper.startScreenCaptureByWindowId(windowId);
    setState(() {
      isScreenSharing = true;
    });
    await helper.joinChannelWithUserAccount(
        token, widget.channelId, userAccount.uId);
  }

  _stopScreenShare() async {
    final helper = await _engine.getScreenShareHelper();
    await helper.destroy().then((value) {
      setState(() {
        isScreenSharing = false;
      });
    }).catchError((err) {
      debugPrint('StopScreenShare $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = userAccount;
    bool isUser = '${user.uId}${user.username}' == widget.channelId;
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(
        bottomNavigationBar: widget.isBroadcaster
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: MainButton(
                  title: 'End Stream',
                  onTap: _leaveChannel,
                ),
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ResponsiveLayout(
              desktopBody: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _renderVideo(user, isScreenSharing),
                        if (isUser)
                          const SizedBox(
                            height: 10,
                          ),
                        if (isUser)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MainButton(
                                onTap: _switchCamera,
                                title: 'Switch Camera',
                                width: size.width * 0.2,
                                height: 35,
                              ),
                              MainButton(
                                onTap: _onToggleMute,
                                title: isMuted ? 'Unmute' : 'Mute',
                                width: size.width * 0.2,
                                height: 35,
                                color: isMuted
                                    ? ColorManager.error
                                    : ColorManager.primary,
                              ),
                              MainButton(
                                onTap: isScreenSharing
                                    ? _stopScreenShare
                                    : _startScreenShare,
                                title: isScreenSharing
                                    ? 'Stop Sharing'
                                    : 'Start Sharing',
                                width: size.width * 0.2,
                                height: 35,
                                color: isScreenSharing
                                    ? ColorManager.error
                                    : ColorManager.primary,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  ChatWidget(channelId: widget.channelId, user: user),
                ],
              ),
              mobileBody: Column(
                children: [
                  _renderVideo(user, isScreenSharing),
                  if (isUser)
                    const SizedBox(
                      height: 10,
                    ),
                  if (isUser)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MainButton(
                          onTap: _switchCamera,
                          title: 'Switch Camera',
                          width: size.width * 0.4,
                          height: 35,
                        ),
                        MainButton(
                          onTap: _onToggleMute,
                          title: isMuted ? 'Unmute' : 'Mute',
                          width: size.width * 0.4,
                          height: 35,
                          color: isMuted
                              ? ColorManager.error
                              : ColorManager.primary,
                        ),
                      ],
                    ),
                  Expanded(
                      child:
                          ChatWidget(channelId: widget.channelId, user: user)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _renderVideo(user, isScreenSharing) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: "${user.uid}${user.username}" == widget.channelId
          ? isScreenSharing
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : const RtcLocalView.SurfaceView(
                  zOrderMediaOverlay: true,
                  zOrderOnTop: true,
                )
          : isScreenSharing
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
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
