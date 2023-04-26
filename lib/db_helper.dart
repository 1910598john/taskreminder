import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataBase {
  Future<Database> initializedDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'tasks.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, task TEXT NOT NULL, time TEXT NOT NULL, status TEXT NOT NULL, repeat TEXT NOT NULL, snooze INTEGER, reminded INTEGER)",
        );
        await db.execute(
          "CREATE TABLE gender(gender TEXT NOT NULL, honorific TEXT NOT NULL)",
        );
      },
    );
  }

  // insert data
  Future<int> insertTask(List<UserTask> task) async {
    int result = 0;
    final Database db = await initializedDB();

    for (var item in task) {
      result = await db.insert('tasks', item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    return result;
  }

  Future<int> updateTaskStatus(int id, String status) async {
    final db = await initializedDB();

    return await db.update(
      'tasks',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> reminded(int id) async {
    final db = await initializedDB();

    return await db.update(
      'tasks',
      {'reminded': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // retrieve data
  Future<List<UserTask>> retrieveTasks() async {
    final Database db = await initializedDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('tasks', columns: null, orderBy: 'id DESC');
    return queryResult.map((e) => UserTask.fromMap(e)).toList();
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
  Future<void> deleteTask(int? id) async {
    final db = await initializedDB();
    await db.delete(
      'tasks',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

class Gender {
  late final String gender;
  late final String honorific;

  Gender({required this.gender, required this.honorific});

  Gender.fromMap(Map<String, dynamic> result)
      : gender = result["gender"],
        honorific = result["honorific"];

  Map<String, Object?> toMap() {
    return {'gender': gender, 'honorific': honorific};
  }
}

class UserTask {
  late final int? id;
  late final String task;
  late final String time;
  late final String status;
  late final String repeat;
  late final int snooze;
  late final int reminded;

  UserTask({
    this.id,
    required this.task,
    required this.time,
    required this.status,
    required this.repeat,
    required this.snooze,
    required this.reminded,
  });

  UserTask.fromMap(Map<String, dynamic> result)
      : id = result["id"],
        task = result["task"],
        time = result["time"],
        status = result["status"],
        repeat = result['repeat'],
        snooze = result['snooze'],
        reminded = result['reminded'];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'task': task,
      'time': time,
      'status': status,
      'repeat': repeat,
      'snooze': snooze,
      'reminded': reminded,
    };
  }
}
