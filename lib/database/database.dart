import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_app_tasks/model/task.dart';

class DataBaseHelper{

  static final DataBaseHelper _instance = new DataBaseHelper.internal();
  factory DataBaseHelper() => _instance;

  final String taskTable = 'TaskTable';
  final String columnId = 'id';
  final String columnTitle = 'title';
  final String columnNotes = 'notes';
  final String columnDueDate = 'due date';
  final String columnStartDate = 'start date';
  final String columnProgress = 'progress';


  List<Task> completed = [];
  List<Task> inProgress = [];

  static Database _db;

  DataBaseHelper.internal();

  Future<Database> get db async {
    if(_db != null){
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'notes.db');

    await deleteDatabase(path); // just for testing
 
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }
  
  _onCreate(Database db, int newVersion) async {
      await db.execute("CREATE TABLE $taskTable($columnId INTEGER PRIMARY KEY, $columnTitle TEXT, $columnNotes TEXT, $columnStartDate TEXT, $columnDueDate TEXT, $columnProgress INTEGER)");
      print("created tables");
  }

  Future<int> saveTask(Task task) async{
      var dbClient = await db;
      var result = await dbClient.insert(taskTable, task.toMap());
      // await dbClient.transaction((txn) async {
      // return await txn.rawInsert(
      //   'INSERT INTO Task(title, notes, createdAt, dueDate, progress) VALUES(' +
      //         '\'' +
      //         task["title"] +
      //         '\'' +
      //         ',' +
      //         '\'' +
      //         task["notes"] +
      //         '\'' +
      //         ',' +
      //         '\'' +
      //         task["start"].toIso8601String() +
      //         '\'' +
      //         ',' +
      //         '\'' +
      //         task["dueDate"].toIso8601String() +
      //         '\'' +
      //         ',' +
      //         '\'' +
      //         task["progress"].toString() +
      //         '\'' +
      //         ')');
      // });
      return result;
      
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
  Future<Task> fetchTasks() async {
    var dbHelper = DataBaseHelper();
    List<Task> tasks = await dbHelper.getTask();
    tasks.forEach((task) {
      if(task.progress == 100){
        completed.add(task);
      }else{
        inProgress.add(task);
      }
    });
  }

  Future close() async{
    var dbClient = await db;
    return dbClient.close();
  }
}