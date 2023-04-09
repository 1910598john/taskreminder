import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class Speech extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Image.asset(
              "assets/images/speech.gif",
            ),
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText('Hello, Sir.',
                      textStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'WorkSans')),
                  TyperAnimatedText('It is time to do your task!',
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
          Container(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 78, 49, 170),
                    foregroundColor: Colors.white,
                    fixedSize: Size(100, 40),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Snooze',
                    style: TextStyle(fontFamily: 'WanSans', fontSize: 15),
                  )),
              const SizedBox(
                width: 50,
                height: 0,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 78, 49, 170),
                      foregroundColor: Colors.white,
                      fixedSize: Size(100, 40)),
                  onPressed: () {},
                  child: Text(
                    'Dismiss',
                    style: TextStyle(fontFamily: 'WanSans', fontSize: 15),
                  ))
            ]),
          )
        ],
      ),
    );
  }
}
