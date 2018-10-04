import 'package:flutter/material.dart';

class Task{
  String _title;
  String _notes;
  int _startDate;
  int _dueDate;
  int _progress;
  int _id;

  Task(
    this._title,
    this._notes,
    this._startDate, 
    this._dueDate,
    this._progress, 
    [this._id]
  );

  Task.map(dynamic obj){
    this._title = obj['title'];
    this._notes = obj['notes'];
    this._startDate = obj['start_Date'];
    this._dueDate = obj['due_Date'];
    this._progress = obj['progress'];
    this._id = obj['id'];
    
  }

  String get title => _title;
  String get notes => _notes;
  int get dueDate => _dueDate;
  int get startDate => _startDate;
  int get progress => _progress;
  int get id => _id;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['title'] = _title;
    map['notes'] = _notes;
    map['start_Date'] = _startDate;
    map['due_Date'] = _dueDate;
    map['progress'] = _progress;

    return map;
  }

  Task.fromMap(Map<String, dynamic> map){
    this._title = map['title'];
    this._notes = map['notes'];
    this._startDate = map['start_Date'];
    this._dueDate = map['due_Date'];
    this._progress = map['progress'];
    this._id = map['id'];
  }
}

class CheckBoxItem{
  String checkBoxItemTitle;
  int checkBoxItemCheck = 0;
  int checkBoxItemId;
  int taskId;


  CheckBoxItem(
    this.checkBoxItemCheck,
    this.checkBoxItemTitle,
    this.taskId,
    [this.checkBoxItemId]
  );

  CheckBoxItem.map(dynamic obj){
    this.checkBoxItemCheck = obj['check_Box_Item_Check'];
    this.checkBoxItemTitle = obj['check_Box_Item_Title'];
    this.taskId = obj['task_Id'];
    this.checkBoxItemId =obj['check_Box_Item_Id'];
  }
  
  
  Map<String, dynamic> toMap() {
  var map = new Map<String, dynamic>();
  if(checkBoxItemId != null){
    map['check_Box_Item_Id'] = checkBoxItemId;
  }
  map['check_Box_Item_Title'] = checkBoxItemTitle;
  map['check_Box_Item_Check'] = checkBoxItemCheck;
  map['task_Id'] = taskId;
  
  return map;
  }

  
}
