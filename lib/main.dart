import 'package:flutter/material.dart';
import 'check_gender.dart';

/*
    

    c
    
*/

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CheckGender(),
    );
  }
}
