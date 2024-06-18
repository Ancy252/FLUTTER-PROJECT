import 'package:flutter/material.dart';
import 'package:my_new_app/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grape Leaf Disease Finder',
      home: MySplash(), // Added const here for consistency and optimization
      debugShowCheckedModeBanner: false,
    );
  }
}
