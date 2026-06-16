import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beauty Booking',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: LoginScreen(), // 👈 This is the login screen
      debugShowCheckedModeBanner: false,
    );
  }
}
