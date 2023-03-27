import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:day_picker/day_picker.dart';
import 'main.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _History createState() => _History();
}

class _History extends State<History> {
  int itemcount = 10;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 178, 141, 255),
        elevation: 0,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
          color: Color.fromARGB(255, 78, 49, 170),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 178, 141, 255),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Column(children: [
            Icon(
              Icons.history,
              size: 100,
              color: Colors.white,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Color.fromARGB(255, 78, 49, 170),
                ),
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Color.fromARGB(255, 78, 49, 170),
                ),
              ],
            ),
            Text(
              'HISTORY',
              style: TextStyle(
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Color.fromARGB(255, 78, 49, 170),
                    ),
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Color.fromARGB(255, 78, 49, 170),
                    ),
                  ],
                  fontSize: 50,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )
          ]),
        ),
        const Divider(),
        Expanded(
            child: Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 70),
                child: ListView.builder(
                    itemCount: itemcount,
                    itemBuilder: ((context, index) => buildTaskList(index))))),
      ]),
    );
  }

  test(index) {
    if (index == (itemcount - 1)) {
      return Container(
        padding: const EdgeInsets.fromLTRB(30, 3, 30, 3),
        child: Column(children: [
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7:30 AM',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    'Eat breakfast',
                    style: TextStyle(
                        color: Color.fromARGB(255, 78, 49, 170), fontSize: 15),
                  )
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.delete_sharp,
                    color: Color.fromARGB(255, 78, 49, 170),
                    size: 30,
                  ),
                  SizedBox(
                    width: 5,
                    height: 0,
                  ),
                  Icon(
                    Icons.repeat,
                    color: Color.fromARGB(255, 78, 49, 170),
                    size: 30,
                  ),
                ],
              )
            ],
          )),
        ]),
      );
    } else {
      return Container(
        padding: const EdgeInsets.fromLTRB(30, 3, 30, 3),
        child: Column(children: [
          Container(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7:30 AM',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    'Eat breakfast',
                    style: TextStyle(
                        color: Color.fromARGB(255, 78, 49, 170), fontSize: 15),
                  )
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.delete_sharp,
                    color: Color.fromARGB(255, 78, 49, 170),
                    size: 30,
                  ),
                  SizedBox(
                    width: 5,
                    height: 0,
                  ),
                  Icon(
                    Icons.repeat,
                    color: Color.fromARGB(255, 78, 49, 170),
                    size: 30,
                  ),
                ],
              )
            ],
          )),
          Divider(
            color: Color.fromARGB(255, 78, 49, 170),
          )
        ]),
      );
    }
  }

  buildTaskList(int index) => test(index);
}
