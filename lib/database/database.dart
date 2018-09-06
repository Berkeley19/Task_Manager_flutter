import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_app_tasks/model/task.dart';

class DBHelper{

  List<Task> completed = [];
  List<Task> inProgress = [];
  // static final DBHelper _instance = new DBHelper().internal();
  // factory DBHelper()=>_instance;
  static Database _db;

  Future<Database> get db async {
    if(_db != null){
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  // DBHelper.internal();

  Future<Database> initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    var _ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _ourDb;
  }

  Future<Task> fetchTasks() async {
    var dbHelper = DBHelper();
    List<Task> tasks = await dbHelper.getTask();
    tasks.forEach((task) {
      if(task.progress == 100){
        completed.add(task);
      }else{
        inProgress.add(task);
      }
    });
  }

  void _onCreate(Database db, int version) async {
      db.execute("CREATE TABLE Task(id INTEGER PRIMARY KEY, title TEXT, notes TEXT, createdAt TEXT, dueDate TEXT, progress INTEGER)");
      print("created tables");
  }

  void saveTask(Task task) async{
      var dbClient = await db;
      await dbClient.transaction((txn) async {
      return await txn.rawInsert(
        'INSERT INTO Task(title, notes, createdAt, dueDate, progress) VALUES(' +
              '\'' +
              task.title +
              '\'' +
              ',' +
              '\'' +
              task.notes +
              '\'' +
              ',' +
              '\'' +
              task.createdAt.toIso8601String() +
              '\'' +
              ',' +
              '\'' +
              task.dueDate.toIso8601String() +
              '\'' +
              ',' +
              '\'' +
              task.progress.toString() +
              '\'' +
              ')');
      });
    }

  Future<List<Task>> getTask() async{
      var dbClient = await db;
      List<Map> list = await dbClient.rawQuery('SELECT * FROM Task');
      List<Task> tasks = new List();
      for(int i=0; i<list.length; i++){
        tasks.add(new Task(list[i]["title"], list[i]["notes"], list[i]["createdAt"], list[i]["dueDate"], list[i]["progress"]));
      }
      print(tasks.length);
      return tasks;
  }
}