import 'package:flutter/material.dart';
import 'package:project_app_tasks/model/task.dart';
import 'package:project_app_tasks/viewCard.dart';
import 'package:project_app_tasks/database/database.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget{
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage>{
  List<Task> taskItem = new List();
  DataBaseHelper manager;

  @override
  void initState(){
    super.initState();
  }
  
  @override
  Widget build(BuildContext context){
    this.manager = DataBaseHelper();
    return new FutureBuilder(
          future: this.manager.getAllTasks(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!=null) {
                return new Scaffold( 
                  resizeToAvoidBottomPadding: false,
                  appBar: new AppBar(title:new Text('Task App'), elevation: 5.0), 
                  body: mainList(), 
                  floatingActionButton: RaisedButton( 
                    child: Text("Create Task"), 
                    color: Colors.cyan, 
                    onPressed: ()async { 
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => ViewCard()),);
                    } 
                  ), 
                );
              } else {
                return new CircularProgressIndicator();
              }
            }else{
              return new Container(width: 0.0, height: 0.0); 
            }
          }
        );
  }

  void forEachTaskAddToCell(List<Widget> taskCellsFunction, List<Task> taskType){
      taskType.forEach((task){
        return taskCellsFunction.add(taskCell(task));
      });
  }

  

  List<Widget> taskBuilder(String title, ProgressState state) {
    List<Widget> taskCells = [];

    taskCells.add(ListTile(title: new Text(title)));
    switch(state){
      case ProgressState.Completed: 
        forEachTaskAddToCell(taskCells, this.manager.completed);
      break;
      case ProgressState.InProgress: 
        forEachTaskAddToCell(taskCells, this.manager.inProgress);
      break;
      case ProgressState.OverDue:
        forEachTaskAddToCell(taskCells, this.manager.overDue);
    }
    return taskCells;
  }

  Widget taskCell(Task task) {
    return new GestureDetector(
      onTap: ()async {
        var route = new MaterialPageRoute(builder:(BuildContext context) => new ViewCard(task: task,));
        var result = await Navigator.of(context).push(route);
        if(result == null){
          return;
        }
        if(result){
          this.manager.getAllTasks();
        }},
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
                          task.progress, ProgressType.DueDate, startDate: task.startDate,
                          dueTime: task.dueDate),
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

  Widget progressStack(int progress, ProgressType type, {int startDate, int dueTime}) {
    int globalProgress;
    int daysLeft;
    double textProgress;
    bool endOfTask = false;
    bool completedEndOfTask = false;
    switch(type){
      case ProgressType.DueDate:
        var dateNow = DateTime.now();
        int dateDiff1 = dueTime - startDate;
        int dateDiff2 = dateNow.millisecondsSinceEpoch - startDate;
        textProgress = dateDiff2 / dateDiff1;
        globalProgress = (textProgress * 100).toInt();
        daysLeft = DateTime.fromMillisecondsSinceEpoch(dateDiff1).day;
        if(daysLeft == 0){
          daysLeft = 0;
          endOfTask = true;
        }if(globalProgress > 100){	        
          globalProgress = 100;	      
          completedEndOfTask = true;  
        }
        break;
        
      case ProgressType.Progress:
        globalProgress = progress;
        textProgress = globalProgress / 100;
        break;    
    }if(ProgressType.Progress ==  type){
      return new Column(
        children:<Widget>[
          new Padding (padding: EdgeInsets.all(4.0), child: completedEndOfTask == true ? new Text('Finished') : new Text('Progress')),
          new Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
              new CircularProgressIndicator(value: textProgress, valueColor: new AlwaysStoppedAnimation<Color>(Colors.cyan)),
              Positioned(child: new Text("$globalProgress%", 
              overflow: TextOverflow.clip, textAlign: TextAlign.center,)
              ),
        ]
        ),
        ]
      );
    }else if(ProgressType.DueDate == type){
      return new Column(
          children:<Widget>[
            new Padding (padding: EdgeInsets.all(4.0), child: endOfTask == true ? new Text('Overdue') : new Text('Days Left')),
            new Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                new CircularProgressIndicator(value: textProgress, valueColor: new AlwaysStoppedAnimation<Color>(Colors.red)),
                Positioned(child: new Text(endOfTask == true ? Icon(Icons.error) : '$daysLeft', 
                overflow: TextOverflow.clip, textAlign: TextAlign.center,),
                ),
              ] 
            ),
          ]
      );
    }
  }

  Widget mainList() {
    return new ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(6.0),
      children: <Widget>[
        new Column(
          children: this.manager.inProgress.isEmpty == false ? taskBuilder("In Progress", ProgressState.InProgress) : <Widget> [
              new Column(
                children: <Widget>[
                  new Icon(Icons.note_add, size: 150.0,),
                  new Text('No tasks in progress', style: new TextStyle(fontWeight: FontWeight.bold),),
                ],
              )
          ],
        ),
        new Column(
            children: this.manager.completed.isEmpty == false ? taskBuilder("Complete", ProgressState.Completed) : <Widget> [],
        ),
        new Column(
          children: this.manager.overDue.isEmpty == false ? taskBuilder("Overdue", ProgressState.OverDue) : <Widget> [],
        ),
        ],
        );
      }
}

enum ProgressType {
  DueDate, Progress
}

enum ProgressState {
  Completed, InProgress, OverDue
}
