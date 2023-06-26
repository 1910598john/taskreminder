import 'package:flutter/material.dart';
import 'package:taskreminder/db_helper.dart';
import 'db_helper.dart';

class History extends StatefulWidget {
  final List<TasksHistory> history;

  const History({Key? key, required this.history});

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
        backgroundColor: const Color.fromARGB(255, 128, 0, 0),
        elevation: 0,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 128, 0, 0),
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
                  color: Color.fromARGB(255, 224, 82, 82),
                ),
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Color.fromARGB(255, 224, 82, 82),
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
                      color: Color.fromARGB(255, 224, 82, 82),
                    ),
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Color.fromARGB(255, 224, 82, 82),
                    ),
                  ],
                  fontSize: 50,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )
          ]),
        ),
        const Divider(),
        widget.history.isEmpty
            ? Row(
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
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Expanded(
                child: Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: widget.history.length,
                        itemBuilder: ((context, index) {
                          String toDo = widget.history[index].task;
                          if (toDo.length > 20) {
                            toDo = "${toDo.substring(0, 20)}..";
                          }

                          if (index == (widget.history.length - 1)) {
                            return Container(
                              padding: const EdgeInsets.fromLTRB(30, 3, 30, 3),
                              child: Column(children: [
                                Container(
                                    child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.history[index].time,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          toDo,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                        Text(
                                          widget.history[index].repeat,
                                          style: const TextStyle(
                                              color: Colors.white,
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
                                                widget.history[index].id);
                                          },
                                          child: const Icon(
                                            Icons.delete_sharp,
                                            color: Colors.white,
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
                              padding: const EdgeInsets.fromLTRB(30, 3, 30, 3),
                              child: Column(children: [
                                Container(
                                    child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.history[index].time,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          toDo,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                        Text(
                                          widget.history[index].repeat,
                                          style: const TextStyle(
                                              color: Colors.white,
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
                                                widget.history[index].id);
                                          },
                                          child: const Icon(
                                            Icons.delete_sharp,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )),
                                const Divider(
                                  color: Colors.white,
                                )
                              ]),
                            );
                          }
                        }))))
      ]),
    );
  }
}
