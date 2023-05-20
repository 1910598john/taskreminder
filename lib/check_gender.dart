import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'package:taskreminder/db_helper.dart';

class CheckGender extends StatefulWidget {
  const CheckGender({Key? key}) : super(key: key);

  @override
  _CheckGender createState() => _CheckGender();
}

class _CheckGender extends State<CheckGender> {
  late DataBase handler;

  Future<int> userGender(gender, honorific) async {
    Gender d = Gender(gender: gender, honorific: honorific);
    List<Gender> userGender = [d];
    return await handler.insertUserGender(userGender);
  }

  @override
  void initState() {
    super.initState();
    handler = DataBase();
    handler.initializedDB().whenComplete(() async {
      handler.getUserGender().then((value) {
        if (value.isNotEmpty) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 178, 141, 255),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'SELECT GENDER',
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
                    fontWeight: FontWeight.bold,
                    fontFamily: 'WanSans',
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
              width: 0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()));
                    await userGender("Male", "Sir");
                  },
                  child: Container(
                      child: const Image(
                    image: AssetImage("assets/images/male.png"),
                    width: 100,
                    height: 100,
                  )),
                ),
                const SizedBox(
                  width: 40,
                  height: 0,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()));
                    await userGender("Female", "Ma'am");
                  },
                  child: Container(
                      child: const Image(
                    image: AssetImage("assets/images/female.png"),
                    width: 100,
                    height: 100,
                  )),
                )
              ],
            ),
          ]),
    );
  }
}
