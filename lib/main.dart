import 'package:flutter/material.dart';
import 'pages/log_in.dart';
import 'pages/sign_up_screen.dart';
import 'pages/personal_information.dart';
import 'pages/two_fact.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Step By Step',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF3D1A6E)),
        useMaterial3: true,
      ),
      home: SignUpScreen(),
    );
  }
}