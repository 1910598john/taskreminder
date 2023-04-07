import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:taskreminder/history.dart';
import 'package:taskreminder/homescreen.dart';
import 'package:taskreminder/set_alarm.dart';
import 'gender.dart';
import 'db_helper.dart';
import 'package:cron/cron.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}
