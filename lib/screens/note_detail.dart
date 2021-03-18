import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/models/note.dart';
import 'package:todo_list/utils/databse_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note,this.appBarTitle);
  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  _NoteDetailState(this.note, this.appBarTitle);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleController.text = note.title;
    descriptionController.text = note.description;
    return WillPopScope(
      onWillPop: (){
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15,left: 10,right: 10),
          child: ListView(
            children: [
              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem){
                    return DropdownMenuItem<String>(
                     value: dropDownStringItem,
                     child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser){
                    setState(() {
                      debugPrint('User Selected $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  }

                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15,bottom: 15),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something Change in Title Text Field');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                    )
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 15,bottom: 15),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something Change in Description Text Field');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: textStyle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      )
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 15,bottom: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Theme.of(context).primaryColorDark,
                        ),
                        child: FlatButton(
                          // color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text('Save',textScaleFactor: 1.5,),
                          onPressed: (){
                            setState(() {
                              debugPrint('Save Button Clicked');
                              _save();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 5,),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Theme.of(context).primaryColorDark,
                        ),
                        child: FlatButton(
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text('Delete',textScaleFactor: 1.5,),
                          onPressed: (){
                            setState(() {
                              debugPrint('Delete Button Clicked');
                              _delete();
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  void moveToLastScreen(){
    Navigator.pop(context, true);
  }

  // Convert the string priority in the form of integer before saving it to database
  void updatePriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority = 1;
        break;

      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to string priority and display it to user in dropdown
  String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1:
        priority = _priorities[0];
        break;

      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle(){
    note.title = titleController.text;
  }

  void updateDescription(){
    note.description = descriptionController.text;
  }

  void _save() async{
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if(note.id != null){
      result = await helper.updateNote(note);
    }else{
      result = await helper.insertNote(note);
    }
    if(result !=0){
      _showAlertDialog('Status', 'Note Saved Successfully');
    }else{
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    moveToLastScreen();
    // case 1: if user is trying to delete the new note i.e he has come to
    // the detail page by pressing the fab of noteList page.

    if(note.id == null){
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // case 2: user is trying to delete the old note that alredy has a valid ID.
    int result = await helper.deleteNote(note.id);
    if(result != 0){
      _showAlertDialog('Status', 'Note Deleted Successfully');
    }else{
      _showAlertDialog('Error', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        Container(
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Theme.of(context).primaryColorDark,
          ),
          child: FlatButton(
            child: Text('Ok',textScaleFactor: 1.5,),
              textColor: Theme.of(context).primaryColorLight,
              onPressed: (){
            Navigator.pop(context);
          }
          ),
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog,
    );
  }
}
