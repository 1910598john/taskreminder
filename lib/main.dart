import 'package:flutter/material.dart';
import 'package:taskreminder/homescreen.dart';
import 'check_gender.dart';
import 'package:taskreminder/db_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  late DataBase handler;
  bool isNewUser = true;

  @override
  void initState() {
    super.initState();
    handler = DataBase();
    handler.initializedDB().whenComplete(() async {
      handler.getUserGender().then((value) {
        if (value.isNotEmpty) {
          setState(() {
            isNewUser = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isNewUser ? const CheckGender() : const HomeScreen(),
    );
  }
}
