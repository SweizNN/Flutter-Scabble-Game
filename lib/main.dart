import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelime Oyunu',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(),
    );
  }
}



