import 'package:flutter/material.dart';
import 'package:project_app_tasks/model/task.dart';
import 'package:project_app_tasks/database/database.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

enum DatePicker {
  StartDate, DueDate
}

class ViewCard extends StatefulWidget{
  final Task task;
  ViewCard({this.task});
 
  static var routeName = '/viewCardRoute';
  @override
  ViewCardState createState() => new ViewCardState();
}

class ViewCardState extends State<ViewCard>{

  DataBaseHelper viewManager = new DataBaseHelper();
  String title = '';
  String notes = '';
  DateTime startDate = DateTime.now();
  DateTime dueDate = DateTime.now();
  int progress = 0;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

  }
  
  final formKey = new GlobalKey<FormState>();

void changeProgress(double value){
  setState(() {
      this.progress = value.toInt();
    });
}

Widget _datePicker(DatePicker date){
  DateTime initialValue;
  switch(date){
    case DatePicker.StartDate: 
      if(widget.task != null){
        print('${widget.task.startDate} start');
        initialValue = DateTime.fromMillisecondsSinceEpoch(widget.task.startDate);
        print(initialValue);
      }else{
        initialValue = DateTime.now();
        print('startdate null');
      }
      break;
    case DatePicker.DueDate:
      if(widget.task != null){
        print('${widget.task.dueDate} due');
        initialValue = DateTime.fromMillisecondsSinceEpoch(widget.task.dueDate);
        print(initialValue);
      }else{
        initialValue = DateTime.now();
        print('duedate null');
      }
      break;
  }
  return new GestureDetector(
    onTap: (){
      showDatePicker(
        context: context,
        initialDate: initialValue,
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
      title: new Text(new DateFormat('MMM, dd yyyy').format(initialValue),
    )
  )
  );
}

void onPressedSnackBar(String text, scaffoldKey){
    var snack = new SnackBar(content: Text(text));
    scaffoldKey.currentState.showSnackBar(snack);
}

 @override
  Widget build(BuildContext context) {
  
    return new Scaffold(
      key: _scaffoldKey,
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
                initialValue: widget.task != null ? widget.task.title : '',
                onSaved: (val){
                  this.title = val;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a Title';
                  }
              },
              ),
              new TextFormField(
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(labelText: 'Notes'),
                 onSaved: (val){
                  this.notes = val;
                },
              ),
              _datePicker(DatePicker.StartDate),
              _datePicker(DatePicker.DueDate),
              new Container(
                child: Column(
                  children: <Widget>[
                    new Text('Progress percentage at ${this.progress}%'),
                    new Slider(
                    min: 0.0,
                    max: 100.0,
                    value: this.progress.toDouble(),
                    activeColor: this.progress == 100 ? Colors.green : Colors.deepOrange,
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
                    if(this.startDate.millisecondsSinceEpoch == this.dueDate.millisecondsSinceEpoch){
                      onPressedSnackBar('Due date and start date must be different.', _scaffoldKey);
                      return;
                    }
                    if(this.dueDate.millisecondsSinceEpoch - this.startDate.millisecondsSinceEpoch < 0){
                      onPressedSnackBar('Due date cannot be before start date.', _scaffoldKey);
                      return;
                    }
                    if(this.dueDate.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch < 0){
                      onPressedSnackBar('Due date must be after today', _scaffoldKey);
                      return;
                    }
                    if(formKey.currentState.validate()){
                      formKey.currentState.save();
                      if(widget.task != null){
                        viewManager.updateTask(Task.fromMap({
                            'id': widget.task.id,
                            'title': this.title,
                            'notes': this.notes,
                            'start_Date': this.startDate,
                            'due_Date': this.dueDate,
                            'progress': this.progress,
                        })).then((_){
                          Navigator.pop(context, true);
                        });
                      }
                      else{
                        print('viewcardsavetask');
                        viewManager.saveTask(Task(
                          this.title, 
                          this.notes,
                          this.startDate.millisecondsSinceEpoch, 
                          this.dueDate.millisecondsSinceEpoch, 
                          this.progress)).then((_){
                          Navigator.pop(context, true);
                        });
                      }
                    }
                },  
                child: widget.task != null ? Text('Update'): Text('Create Task'),),)
            ],
          ),
        ),
      ),
    );
  }
}