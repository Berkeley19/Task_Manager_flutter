import 'package:flutter/material.dart';

class Task{
  String title;
  String notes;
  DateTime createdAt;
  DateTime dueDate;
  int progress;
  String id;
  Task(
    this.title,
    this.notes,
    this.createdAt, 
    this.dueDate,
    this.progress,
    {this.id}
  );

  Task.fromMap(Map map){
    title = map[title];
    notes = map[notes];
    createdAt = map[createdAt];
    dueDate = map[dueDate];
    progress = map[progress];
  }
  
}
