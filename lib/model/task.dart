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

  );

  Task.map(dynamic obj){
    this._title = obj['title'];
    this._notes = obj['notes'];
    this._startDate = obj['start date'];
    this._dueDate = obj['due date'];
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
      map['id'] = id;
    }
    map['title'] = _title;
    map['notes'] = _notes;
    map['start date'] = _startDate;
    map['due date'] = _dueDate;
    map['progress'] = _progress;
    map['id'] = _id;

    return map;
  }

  Task.fromMap(Map<String, dynamic> map){
    this._title = map['title'];
    this._notes = map['notes'];
    this._startDate = map['start date'];
    this._dueDate = map['due Date'];
    this._progress = map['progress'];
    this._id = map['id'];

  }
  
}
