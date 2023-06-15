import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:taskreminder/homescreen.dart';

class DataBase {
  Future<Database> initializedDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'tasks.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, task TEXT NOT NULL, time TEXT NOT NULL, status TEXT NOT NULL, repeat TEXT NOT NULL, reminded INTEGER)",
        );
        await db.execute(
          "CREATE TABLE gender(gender TEXT NOT NULL, honorific TEXT NOT NULL)",
        );
        await db.execute(
          "CREATE TABLE history(id INTEGER PRIMARY KEY AUTOINCREMENT, task TEXT NOT NULL, time TEXT NOT NULL, repeat TEXT NOT NULL)",
        );
      },
    );
  }

  // tasks db operations
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

  Future<int> isReminded(int id, int n) async {
    final db = await initializedDB();

    return await db.update(
      'tasks',
      {'reminded': n},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<UserTask>> retrieveTasks() async {
    final Database db = await initializedDB();
    final List<Map<String, Object?>> queryResult =
        await db.query('tasks', columns: null, orderBy: 'id DESC');
    return queryResult.map((e) => UserTask.fromMap(e)).toList();
  }

  Future<void> deleteTask(int? id) async {
    final db = await initializedDB();
    await db.delete(
      'tasks',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  //gender db operations
  Future<int> insertUserGender(List<Gender> task) async {
    int result = 0;
    final Database db = await initializedDB();
    for (var item in task) {
      result = await db.insert('gender', item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    return result;
  }

  Future<List<Gender>> getUserGender() async {
    final Database db = await initializedDB();
    final List<Map<String, Object?>> queryResult = await db.query('gender');
    return queryResult.map((e) => Gender.fromMap(e)).toList();
  }

  //history db operations
  Future<int> insertHistory(List<TasksHistory> task) async {
    int result = 0;
    final Database db = await initializedDB();

    for (var item in task) {
      result = await db.insert('history', item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    return result;
  }

  Future<void> removeDuplicates() async {
    final Database db = await initializedDB();
    final List<Map<String, Object?>> queryResult = await db
        .rawQuery('SELECT * FROM history GROUP BY time ORDER BY id DESC');
    await db.execute('DELETE FROM history');

    queryResult.forEach((element) {
      db.insert('history', element);
    });
  }

  Future<List<TasksHistory>> retrieveDoneTasks() async {
    await removeDuplicates();

    final Database db = await initializedDB();
    final List<Map<String, Object?>> queryResult =
        await db.rawQuery('SELECT * FROM history ORDER BY id DESC');

    return queryResult.map((e) => TasksHistory.fromMap(e)).toList();
  }

  Future<void> deleteHistory(int? id) async {
    final db = await initializedDB();
    await db.delete(
      'history',
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
  late final int reminded;

  UserTask({
    this.id,
    required this.task,
    required this.time,
    required this.status,
    required this.repeat,
    required this.reminded,
  });

  UserTask.fromMap(Map<String, dynamic> result)
      : id = result["id"],
        task = result["task"],
        time = result["time"],
        status = result["status"],
        repeat = result['repeat'],
        reminded = result['reminded'];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'task': task,
      'time': time,
      'status': status,
      'repeat': repeat,
      'reminded': reminded
    };
  }
}

class TasksHistory {
  late final int? id;
  late final String task;
  late final String time;
  late final String repeat;

  TasksHistory({
    this.id,
    required this.task,
    required this.time,
    required this.repeat,
  });

  TasksHistory.fromMap(Map<String, dynamic> result)
      : id = result["id"],
        task = result["task"],
        time = result["time"],
        repeat = result["repeat"];

  Map<String, Object?> toMap() {
    return {'id': id, 'task': task, 'time': time, 'repeat': repeat};
  }
}
