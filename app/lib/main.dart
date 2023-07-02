import 'package:app/screens/home.dart';
import 'package:app/screens/login_register.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";

import 'models/auth.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // home: MyHomePage(
      //   title: 'Flutter Demo Home Page',
      //   cameras: _cameras,
      // ),
      home: StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MyHomePage(
              title: "",
              cameras: _cameras,
            );
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
