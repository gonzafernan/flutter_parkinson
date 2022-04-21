import 'package:flutter/material.dart';
import 'package:flutter_parkinson/drawing_page.dart';
//import 'package:parkinsons_test/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parkinsons Drawing Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const HomePage(),
      home: const DrawingPage(),
    );
  }
}
