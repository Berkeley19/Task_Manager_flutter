import 'package:flutter/material.dart';
import 'package:project_app_tasks/model/task.dart';
import 'package:project_app_tasks/viewCard.dart';
import 'package:project_app_tasks/database/database.dart';

class HomePage extends StatefulWidget{
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage>{
    
  DBHelper manager;
  
  @override
  Widget build(BuildContext context){
    this.manager = new DBHelper();
    return new Scaffold(
      appBar: new AppBar(),
      body: mainList(),
      floatingActionButton: RaisedButton(
        child: Text("Create Task"),
        color: Colors.cyan,
        onPressed: (){
          var route = new MaterialPageRoute(builder:(BuildContext context) => new ViewCard());
          Navigator.of(context).push(route);
        }
      ),
    );
  }

  List<Widget> taskBuilder(String title, ProgressState state) {
    List<Widget> taskCells = [];

    taskCells.add(ListTile(title: new Text(title)));
    switch(state){
      case ProgressState.Completed: 
        this.manager.completed.forEach((task) {
        taskCells.add(taskCell(task));
      });
      break;
      case ProgressState.InProgress: 
        this.manager.inProgress.forEach((task) {
        taskCells.add(taskCell(task));
      });
      break;
    }
    return taskCells;
  }

  Widget taskCell(Task task) {
    return new GestureDetector(
      onTap: (){
        // to new page
        var route = new MaterialPageRoute(builder:(BuildContext context) => new ViewCard());
        Navigator.of(context).push(route);
      },
      child: Padding(
        padding: new EdgeInsets.all(6.0), 
          child: Card(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: ListTile(
                      title: Text("${task.title}", overflow: TextOverflow.clip),
                      subtitle: Text("${task.notes}", overflow: TextOverflow.ellipsis)
                      )
                    ),
                    new Expanded(
                        child: progressStack(
                          task.progress, ProgressType.DueDate, createdAt: task.createdAt, dueTime: task.dueDate)
                    ),
                    new Expanded(
                        child: progressStack(task.progress, ProgressType.Progress)
                    ),
                  ],
                ),
              ]
            )
        )
      )
    );
  }

  Widget progressStack(int progress, ProgressType type, {DateTime createdAt, DateTime dueTime}) {
    int globalProgress;
    double textProgress;
    switch(type){
      case ProgressType.DueDate:
        var dateNow = DateTime.now();
        Duration dateDiff1 = dueTime.difference(createdAt);
        Duration dateDiff2 = dateNow.difference(createdAt);
        textProgress = dateDiff2.inDays / dateDiff1.inDays;
        globalProgress = (textProgress * 100).toInt();
        break;
      case ProgressType.Progress:
        globalProgress = progress;
        textProgress = globalProgress / 100;
        break;    
    }
    return new Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        // circular progress bar + percentage
        CircularProgressIndicator(value: textProgress, valueColor: new AlwaysStoppedAnimation<Color>(Colors.cyan)),
        Positioned(child: new Text("$globalProgress%", 
        overflow: TextOverflow.clip, textAlign: TextAlign.center,)
        ),
      ]);
  }

  Widget mainList() {
    return new ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(15.0),
      children: <Widget>[
        new Column(
          children: taskBuilder("In Progress", ProgressState.InProgress),
        ),
        new Column(
            children: taskBuilder("Complete", ProgressState.Completed),
        ),
        ],
        );
      }
}

enum ProgressType {
  DueDate, Progress
}

enum ProgressState {
  Completed, InProgress
}
