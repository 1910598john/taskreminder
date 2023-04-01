import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
//import 'tasks.dart';

class DataBase {
  Future<Database> initializedDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'tasks.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY, task TEXT NOT NULL, time TEXT NOT NULL, status TEXT NOT NULL, repeat TEXT NOT NULL, snooze TEXT NOT NULL)",
        );
        await db.execute(
          "CREATE TABLE gender(gender TEXT NOT NULL, honorific TEXT NOT NULL)",
        );
      },
    );
  }

  // insert data
  Future<int> insertTask(List<Tasks2> task) async {
    int result = 0;
    final Database db = await initializedDB();
    for (var item in task) {
      result = await db.insert('tasks', item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    return result;
  }

  // retrieve data
  Future<List<Tasks2>> retrieveTasks() async {
    final Database db = await initializedDB();
    final List<Map<String, Object?>> queryResult = await db.query('tasks');
    return queryResult.map((e) => Tasks2.fromMap(e)).toList();
  }

  // insert data
  Future<int> insertUserGender(List<Gender> task) async {
    int result = 0;
    final Database db = await initializedDB();
    for (var item in task) {
      result = await db.insert('gender', item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    return result;
  }

  // retrieve data
  Future<List<Gender>> getUserGender() async {
    final Database db = await initializedDB();
    final List<Map<String, Object?>> queryResult = await db.query('gender');
    return queryResult.map((e) => Gender.fromMap(e)).toList();
  }

  // delete user
  Future<void> deleteTask(int id) async {
    final db = await initializedDB();
    await db.delete(
      'tasks',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

class Gender {
  //task, time, status, weekday, repeat
  late final String gender;
  late final String honorific;
  Gender({required this.gender, required this.honorific});

  Gender.fromMap(Map<String, dynamic> result)
      : gender = result["gender"],
        honorific = result["honorific"];
  Map<String, Object> toMap() {
    return {'gender': gender, 'honorific': honorific};
  }
}

class Tasks2 {
  //task, time, status, weekday, repeat
  late final String task;
  late final String time;
  late final String status;
  late final String repeat;
  late final String snooze;

  Tasks2({
    required this.task,
    required this.time,
    required this.status,
    required this.repeat,
    required this.snooze,
  });

  Tasks2.fromMap(Map<String, dynamic> result)
      : task = result["task"],
        time = result["time"],
        status = result["status"],
        repeat = result['repeat'],
        snooze = result['snooze'];
  Map<String, Object> toMap() {
    return {
      'task': task,
      'time': time,
      'status': status,
      'repeat': repeat,
      'snooze': snooze
    };
  }
}
