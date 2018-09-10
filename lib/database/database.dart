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

  Future<List> getAllTasks()async {
    var dbClient = await db;
    var result = await dbClient.query(taskTable, columns: [columnId, columnTitle, columnNotes, columnStartDate, columnDueDate, columnProgress]);
    return result.toList();
  }

  Future<Task> getTask(int id) async{
      var dbClient = await db;
       List<Map> result = await dbClient.query(taskTable,
        columns: [columnId, columnTitle, columnNotes, columnStartDate, columnDueDate, columnProgress],
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
//    return await dbClient.rawDelete('DELETE FROM $tableNote WHERE $columnId = $id');
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