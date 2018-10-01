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
  final String columnDueDate = 'due_Date';
  final String columnStartDate = 'start_Date';
  final String columnProgress = 'progress';
  final String columnCheckBoxItemTitle = 'view_Card_Title';
  final String columnCheckBoxItemCheck = 'view_Card_Check';


  List<Task> completed = [];
  List<Task> inProgress = [];
  List<Task> overDue = [];

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
    String path = join(databasesPath, 'tasks.db');

    await deleteDatabase(path); // just for testing
 
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }
  
  _onCreate(Database db, int newVersion) async {
      await db.execute("CREATE TABLE IF NOT EXISTS $taskTable($columnId INTEGER PRIMARY KEY, $columnTitle TEXT, $columnNotes TEXT, $columnStartDate INTEGER, $columnDueDate INTEGER, $columnProgress INTEGER)");
      print("created tables");
  }

  Future<int> saveTask(Task task) async{
      var dbClient = await db;
      print('savetaskb4');
      var result = await dbClient.insert(taskTable, task.toMap());
      print('savetask');
      return result;
    }

  Future<bool> getAllTasks() async {
    var dbClient = await db;
    var result = await dbClient.query(taskTable, columns: [columnId, columnTitle, columnNotes, columnStartDate, columnDueDate, columnProgress]);
    completed.clear();
    inProgress.clear();
    overDue.clear();
    result.forEach((task){
      if(task[columnProgress] == 100){
        completed.add(Task.fromMap(task));
      }else if(task[columnDueDate] < DateTime.now().millisecondsSinceEpoch){
        print('overdue added');
        overDue.add(Task.fromMap(task));
      }
      else{
        inProgress.add(Task.fromMap(task));
      }
    });
    return true;

  }

  Future<Task> getTask(int id) async{
      var dbClient = await db;
       List<Map> result = await dbClient.query(taskTable,
        columns: [columnId, columnTitle, columnNotes, columnStartDate, columnDueDate, columnProgress, columnCheckBoxItemCheck, columnCheckBoxItemTitle],
        where: '$columnId = ?',
        whereArgs: [id]);
      print(result.length);
      if(result.length > 0){
      return new Task.fromMap(result.first);
      }

      return null;
  }
  Future<int> deleteTask(int id) async {
    var dbClient = await db;
    return await dbClient.delete(taskTable, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateTask(Task task) async{
    var dbClient = await db;
    return await dbClient.update(taskTable, task.toMap(), where: "$columnId = ?", whereArgs: [task.id]);
  }

  Future close() async{
    var dbClient = await db;
    return dbClient.close();
  }
}