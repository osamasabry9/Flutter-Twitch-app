import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:twitch_clone/app/helper/cache_helper.dart';
import 'package:twitch_clone/app/utils/constants_manager.dart';

import 'app/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await CacheHelper.init();
  AppConstants.uId = CacheHelper.getData(key: 'uId');
  runApp(const MyApp());
}
