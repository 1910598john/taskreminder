import 'package:flutter/material.dart';
import 'package:taskreminder/db_helper.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  _History createState() => _History();
}

class _History extends State<History> {
  late DataBase handler;

  @override
  void initState() {
    super.initState();
    handler = DataBase();
    handler.initializedDB();
  }

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
          child: Column(children: const [
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
        FutureBuilder(
            future: handler.retrieveDoneTasks(),
            builder: (BuildContext context,
                AsyncSnapshot<List<TasksHistory>> snapshot) {
              if (snapshot.data!.isEmpty) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      height: 200,
                      width: 0,
                    ),
                    Text(
                      'No item',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 78, 49, 170),
                      ),
                    ),
                  ],
                );
              } else {
                return Expanded(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.length,
                            itemBuilder: ((context, index) {
                              String toDo = snapshot.data![index].task;
                              if (toDo.length > 20) {
                                toDo = "${toDo.substring(0, 20)}..";
                              }
                              if (index == (snapshot.data!.length - 1)) {
                                return Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 3, 30, 3),
                                  child: Column(children: [
                                    Container(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data![index].time,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                            Text(
                                              toDo,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 78, 49, 170),
                                                  fontSize: 13),
                                            ),
                                            Text(
                                              snapshot.data![index].repeat,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 78, 49, 170),
                                                  fontSize: 13),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {});

                                                handler.deleteHistory(
                                                    snapshot.data![index].id);
                                              },
                                              child: const Icon(
                                                Icons.delete_sharp,
                                                color: Color.fromARGB(
                                                    255, 78, 49, 170),
                                                size: 30,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    )),
                                  ]),
                                );
                              } else {
                                return Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 3, 30, 3),
                                  child: Column(children: [
                                    Container(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data![index].time,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                            Text(
                                              toDo,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 78, 49, 170),
                                                  fontSize: 13),
                                            ),
                                            Text(
                                              snapshot.data![index].repeat,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 78, 49, 170),
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {});

                                                handler.deleteHistory(
                                                    snapshot.data![index].id);
                                              },
                                              child: const Icon(
                                                Icons.delete_sharp,
                                                color: Color.fromARGB(
                                                    255, 78, 49, 170),
                                                size: 30,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    )),
                                    const Divider(
                                      color: Color.fromARGB(255, 78, 49, 170),
                                    )
                                  ]),
                                );
                              }
                            }))));
              }
            })
      ]),
    );
  }
}
