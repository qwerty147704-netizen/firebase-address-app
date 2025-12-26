import 'package:firebase_address_app/firebase_options.dart';
import 'package:firebase_address_app/view/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async{ // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform // 현 플랫폼 기준으로 인증
  );             // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Home(),
    );
  }
}