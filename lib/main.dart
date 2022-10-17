import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:twitch_clone/app/helper/cache_helper.dart';
import 'package:twitch_clone/app/utils/constants_manager.dart';

import 'app/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCoXG_O_nz8-94JHP4iHt9Y2sjjLYhJ-dA",
          authDomain: "twitch-clone-522bd.firebaseapp.com",
          projectId: "twitch-clone-522bd",
          storageBucket: "twitch-clone-522bd.appspot.com",
          messagingSenderId: "65331584605",
          appId: "1:65331584605:web:903a94c3ebec6b32e577b4"),
    );
  } else {
    await Firebase.initializeApp();
  }

  await CacheHelper.init();
  AppConstants.uId = CacheHelper.getData(key: 'uId');
  runApp(const MyApp());
}
