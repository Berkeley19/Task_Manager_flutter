import 'package:flutter/material.dart';
import 'package:project_app_tasks/model/task.dart';
import 'package:project_app_tasks/database/database.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

enum DatePicker {
  StartDate, DueDate
}

class ViewCard extends StatefulWidget{
  DBHelper dataManager;
  ViewCard({DBHelper this.dataManager});
  static var routeName = '/viewCardRoute';
  @override
  ViewCardState createState() => new ViewCardState();

}

class ViewCardState extends State<ViewCard>{
  Task task = new Task("", "",  null,  null, 0);

  String title;
  String notes;
  DateTime startDate = DateTime.now();
  DateTime dueDate = DateTime.now();
  int progress = 0;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

void changeProgress(double value){
  setState(() {
      this.progress = value.toInt();
    });
}



Widget _datePicker(DatePicker date){
  return new GestureDetector(
    onTap: (){
      showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(1971),
        lastDate: new DateTime(2120),
      ).then((DateTime value) {
        if(value == null){
          return;
        }
        setState(() {
          date == DatePicker.StartDate ? this.startDate = value : this.dueDate = value;
        });
      });
    },
    child: ListTile(
      leading: date == DatePicker.StartDate ? new Text('Start date'): new Text('Due Date'),
      title: date == DatePicker.StartDate ? new Text(new DateFormat('MMM, dd yyyy').format(this.startDate)): new Text(new DateFormat('MMM, dd yyyy').format(this.dueDate),
    )
  )
  );
}

 @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: new Text('New Task'),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Form(
          key: formKey,
          child: new Column(
            children: [
              new TextFormField(
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(labelText: 'Title'),
                validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter a Title';
                }
              },
              ),
              new TextFormField(
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(labelText: 'Notes'),
                validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some Notes';
                }
              },
              ),
              _datePicker(DatePicker.StartDate),
              _datePicker(DatePicker.DueDate),
              new Container(
                child: Column(
                  children: <Widget>[
                    new Text('Progress percentage is ${this.progress}%'),
                    new Slider(
                    min: 0.0,
                    max: 100.0,
                    value: this.progress.toDouble(),
                    onChanged: (double value){changeProgress(value);}
                  )
                  ],
                )
              ),
              new Container(
                margin: const EdgeInsets.only(top: 10.0), 
                padding: const EdgeInsets.symmetric(vertical: 16.0), 
                child: new RaisedButton(
                  onPressed: () async {
                    if(formKey.currentState.validate()){
                      formKey.currentState.save();
                      var employee = Task(title,notes,startDate,dueDate,progress);
                      await widget.dataManager.saveTask(employee);
                      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Processing Data')));
                    }
                },  
                child: new Text('Create Task'),),)
            ],
          ),
        ),
      ),
    );
  }
}