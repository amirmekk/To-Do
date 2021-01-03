import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/helpers/database_helper.dart';
import 'package:todo/models/task_model.dart';
import 'package:todo/screens/todo_list_screen.dart';

class AddTaskScreen extends StatefulWidget {
  final Task task;
  AddTaskScreen({this.task});
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> priorities = ['Low', 'Medium', 'High'];
  String _title = '', _priority = '';
  DateTime _date = DateTime.now();
  TextEditingController _dateController = TextEditingController();
  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date) {
      setState(() => _date = date);
      _dateController.text = _dateFormatter.format(_date);
    }
  }

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      print('$_title , $_date , $_priority');
      //insert task to database if everything is filled out correctly
      Task task = Task(title: _title, priority: _priority, date: _date);
      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
        // OR update existing task
      } else {
        task.status = widget.task.status;
        task.id = widget.task.id;
        DatabaseHelper.instance.updateTask(task);
      }
      // widget.updateTaskList();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ToDoListScreen(),
        ),
      );
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTask(widget.task.id);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ToDoListScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task.title;
      _priority = widget.task.priority;
      _date = widget.task.date;
    }
    _dateController.text = _dateFormatter.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.1,
                  MediaQuery.of(context).size.height * 0.1,
                  MediaQuery.of(context).size.width * 0.1,
                  0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ToDoListScreen(),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.task == null ? 'Add Task' : 'Update Task',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // title
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                          child: TextFormField(
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: TextStyle(fontSize: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (input) => input.trim().isEmpty
                                ? 'Please enter a task title'
                                : null,
                            onSaved: (input) => _title = input,
                            initialValue: _title,
                          ),
                        ),
                        // date
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                          child: TextFormField(
                            readOnly: true,
                            controller: _dateController,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: TextStyle(fontSize: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onTap: _handleDatePicker,
                          ),
                        ),
                        //priority
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                          child: DropdownButtonFormField(
                            items: priorities.map((String priority) {
                              return DropdownMenuItem(
                                child: Text(
                                  priority,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                                value: priority,
                              );
                            }).toList(),
                            icon: Icon(Icons.arrow_drop_down_circle_outlined),
                            iconEnabledColor: Theme.of(context).primaryColor,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              labelStyle: TextStyle(fontSize: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (priority) => _priority == null
                                ? 'Please select a priority level'
                                : null,
                            onChanged: (val) {
                              setState(() {
                                _priority = val;
                              });
                            },
                            //value: _priority,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: FlatButton(
                            onPressed: _submit,
                            child: Text(
                              widget.task == null ? 'Add' : 'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        widget.task != null
                            ? Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                height: 60,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: FlatButton(
                                  onPressed: _delete,
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
