import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:taskreminder/homescreen.dart';

class Speech extends StatefulWidget {
  final String task;
  final String time;
  final String honorific;
  final FlutterTts flutterTts;
  const Speech({
    Key? key,
    required this.task,
    required this.time,
    required this.honorific,
    required this.flutterTts,
  }) : super(key: key);

  @override
  _Speech createState() => _Speech();
}

class _Speech extends State<Speech> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: MaterialApp(
            home: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                child: Image.asset(
                  "assets/images/speech.gif",
                ),
              ),
              Container(
                child: Text(
                  widget.time,
                  style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontFamily: 'WorkSans'),
                ),
              ),
              const SizedBox(
                height: 50,
                width: 0,
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText('Hello, ${widget.honorific}.',
                          textStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'WorkSans')),
                      TyperAnimatedText('It is time to ${widget.task}.',
                          textStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'WorkSans',
                              overflow: TextOverflow.ellipsis),
                          speed: Duration(milliseconds: 30)),
                    ],
                    repeatForever: true,
                  )),
              const SizedBox(
                height: 100,
                width: 0,
              ),
              Expanded(
                  child: Container(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        fixedSize: Size(100, 40),
                      ),
                      onPressed: () async {
                        SystemNavigator.pop();
                      },
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(fontFamily: 'WanSans', fontSize: 15),
                      )),
                  const SizedBox(
                    width: 70,
                    height: 0,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          fixedSize: Size(100, 40)),
                      onPressed: () async {
                        SystemNavigator.pop();
                      },
                      child: const Text(
                        'Snooze',
                        style: TextStyle(fontFamily: 'WanSans', fontSize: 15),
                      ))
                ]),
              ))
            ],
          ),
        )));
  }
}
