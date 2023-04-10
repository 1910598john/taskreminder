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
    return MaterialApp(
        home: Scaffold(
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
                    fontFamily: 'Coffee',
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
                  onTap: () async {
                    await userGender("Male", "Sir");
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()));
                  },
                  child: Container(
                      child: Image(
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
                  onTap: () async {
                    await userGender("Female", "Ma'am");
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()));
                  },
                  child: Container(
                      child: Image(
                    image: AssetImage("assets/images/female.png"),
                    width: 100,
                    height: 100,
                  )),
                )
              ],
            ),
          ]),
    ));
  }
}
