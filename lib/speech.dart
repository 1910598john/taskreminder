import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'homescreen.dart';
import 'package:volume_control/volume_control.dart';

FlutterTts flutterTts = FlutterTts();
bool? running;

class Speech extends StatefulWidget {
  final String task;
  final String time;
  final String honorific;
  final Function startservice;
  final int len;
  final int snooze;
  const Speech(
      {Key? key,
      required this.task,
      required this.time,
      required this.honorific,
      required this.startservice,
      required this.len,
      required this.snooze})
      : super(key: key);

  @override
  _Speech createState() => _Speech();
}

class _Speech extends State<Speech> {
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    speak();
    setVolume();
  }

  void speak() async {
    setState(() {
      running = true;
    });
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(.3);
    await flutterTts.setSpeechRate(0.5);
    while (running!) {
      await flutterTts
          .speak("${widget.honorific}, It is time for you to ${widget.task}");
      await flutterTts.awaitSpeakCompletion(true);
      Future.delayed(const Duration(seconds: 8));
    }
  }

  void setVolume() async {
    // Get the current volume, min=0, max=1
    double _val = await VolumeControl.volume;

    if (_val <= 0.4) {
      VolumeControl.setVolume(0.7);
    }
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
                padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
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
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText('Hello, ${widget.honorific}.',
                          textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'WorkSans')),
                      TyperAnimatedText('It is time to ${widget.task}.',
                          textStyle: const TextStyle(
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
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 30),
                      child: widget.snooze == 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        fixedSize: Size(120, 40),
                                      ),
                                      onPressed: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        const HomeScreen()));
                                        setState(() {
                                          running = false;
                                        });
                                        await flutterTts.stop();
                                      },
                                      child: const Text(
                                        'Dismiss',
                                        style: TextStyle(
                                            fontFamily: 'WanSans',
                                            fontSize: 15),
                                      )),
                                ])
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        fixedSize: Size(120, 40),
                                      ),
                                      onPressed: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        const HomeScreen()));
                                        setState(() {
                                          running = false;
                                        });
                                        await flutterTts.stop();
                                      },
                                      child: const Text(
                                        'Dismiss',
                                        style: TextStyle(
                                            fontFamily: 'WanSans',
                                            fontSize: 15),
                                      )),
                                  const SizedBox(
                                    width: 70,
                                    height: 0,
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor:
                                              Color.fromRGBO(255, 255, 255, 1),
                                          fixedSize: Size(120, 40)),
                                      onPressed: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        const HomeScreen()));
                                        setState(() {
                                          running = false;
                                        });
                                        await flutterTts.stop();
                                      },
                                      child: const Text(
                                        'Snooze',
                                        style: TextStyle(
                                            fontFamily: 'WanSans',
                                            fontSize: 15),
                                      ))
                                ])))
            ],
          ),
        )));
  }
}
