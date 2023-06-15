import 'package:flutter/material.dart';
import 'package:taskreminder/db_helper.dart';

class Tasks extends StatefulWidget {
  final Function start;
  final Function cancelAll;

  const Tasks({Key? key, required this.start, required this.cancelAll})
      : super(key: key);

  @override
  _Tasks createState() => _Tasks();
}

class _Tasks extends State<Tasks> {
  late DataBase handler;
  List<bool> status = [];

  void updateTask(id, status) async {
    await handler.updateTaskStatus(id, status);
  }

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
        backgroundColor: const Color.fromARGB(255, 178, 141, 255),
        elevation: 0,
        leading: BackButton(
          color: const Color.fromARGB(255, 78, 49, 170),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 178, 141, 255),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Column(children: const [
            Icon(
              Icons.task,
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
              'TASKS',
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
            future: handler.retrieveTasks(),
            builder:
                (BuildContext context, AsyncSnapshot<List<UserTask>> snapshot) {
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
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.length,
                            itemBuilder: ((context, index) {
                              late bool stat;
                              String toDo = snapshot.data![index].task;
                              if (toDo.length > 20) {
                                toDo = "${toDo.substring(0, 20)}..";
                              }
                              if (snapshot.data![index].status == "active") {
                                stat = true;
                              } else {
                                stat = false;
                              }
                              status.add(stat);
                              if (index == (snapshot.data!.length - 1)) {
                                return Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 3, 30, 3),
                                  child: Column(children: [
                                    Container(
                                        child: InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () {
                                              showDialog<void>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(snapshot
                                                          .data![index].time),
                                                      content: Container(
                                                        height: 70,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              snapshot
                                                                  .data![index]
                                                                  .task,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                              width: 0,
                                                            ),
                                                            Text(
                                                              snapshot
                                                                  .data![index]
                                                                  .repeat,
                                                              style: TextStyle(
                                                                  fontSize: 13),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                              width: 0,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              setState(() {});
                                                              status.removeAt(
                                                                  index);

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();

                                                              handler.deleteTask(
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .id);

                                                              await widget
                                                                  .start();
                                                            },
                                                            child: const Text(
                                                              'DELETE',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        78,
                                                                        49,
                                                                        170),
                                                              ),
                                                            )),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                              'OK',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        78,
                                                                        49,
                                                                        170),
                                                              ),
                                                            ))
                                                      ],
                                                    );
                                                  });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      snapshot
                                                          .data![index].time,
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
                                                      snapshot
                                                          .data![index].repeat,
                                                      style: const TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 78, 49, 170),
                                                          fontSize: 13),
                                                    )
                                                  ],
                                                ),
                                                Switch(
                                                  // This bool value toggles the switch.
                                                  value: status[index],
                                                  activeColor:
                                                      const Color.fromARGB(
                                                          255, 78, 49, 170),
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      status[index] = value;
                                                    });
                                                    if (status[index] == true) {
                                                      updateTask(
                                                          snapshot
                                                              .data![index].id,
                                                          'active');
                                                    } else {
                                                      updateTask(
                                                          snapshot
                                                              .data![index].id,
                                                          'disabled');
                                                    }
                                                    widget.start();

                                                    // This is called when the user toggles the switch.
                                                  },
                                                )
                                              ],
                                            ))),
                                  ]),
                                );
                              } else {
                                return Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 3, 30, 3),
                                  child: Column(children: [
                                    Container(
                                        child: InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () {
                                              showDialog<void>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(snapshot
                                                          .data![index].time),
                                                      content: Container(
                                                        height: 70,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .task,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            15)),
                                                            const SizedBox(
                                                              height: 4,
                                                              width: 0,
                                                            ),
                                                            Text(
                                                              snapshot
                                                                  .data![index]
                                                                  .repeat,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          13),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                              width: 0,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              setState(() {});
                                                              status.removeAt(
                                                                  index);

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();

                                                              handler.deleteTask(
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .id);
                                                              await widget
                                                                  .start();
                                                            },
                                                            child: const Text(
                                                              'DELETE',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        78,
                                                                        49,
                                                                        170),
                                                              ),
                                                            )),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                              'OK',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        78,
                                                                        49,
                                                                        170),
                                                              ),
                                                            ))
                                                      ],
                                                    );
                                                  });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      snapshot
                                                          .data![index].time,
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
                                                      snapshot
                                                          .data![index].repeat,
                                                      style: const TextStyle(
                                                          color: Color.fromARGB(
                                                              255, 78, 49, 170),
                                                          fontSize: 13),
                                                    )
                                                  ],
                                                ),
                                                Switch(
                                                  // This bool value toggles the switch.
                                                  value: status[index],
                                                  activeColor:
                                                      const Color.fromARGB(
                                                          255, 78, 49, 170),
                                                  onChanged: (bool value) {
                                                    // This is called when the user toggles the switch.
                                                    setState(() {
                                                      status[index] = value;
                                                    });
                                                    if (status[index] == true) {
                                                      updateTask(
                                                          snapshot
                                                              .data![index].id,
                                                          'active');
                                                    } else {
                                                      updateTask(
                                                          snapshot
                                                              .data![index].id,
                                                          'disabled');
                                                    }
                                                    widget.start();
                                                  },
                                                )
                                              ],
                                            ))),
                                    const Divider(
                                        color: Color.fromARGB(255, 78, 49, 170))
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
