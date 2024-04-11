
import 'package:aneez_notes/main.dart';
import 'package:aneez_notes/models/notes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Note extends StatefulWidget {
  final Notes notes;

  Note({Key key, @required this.notes}) : super(key: key);

  // MyApp ma;

  @override
  _NoteState createState() => _NoteState();
}

var primaryColour = const Color(0xffd03056);
// var secondaryColour = const Color(0xffB6294A);
var secondaryColour = const Color(0xff791C31);
var tertiaryColour = const Color(0xff333534);

final db = FirebaseFirestore.instance;

class _NoteState extends State<Note> {
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _textController = new TextEditingController();
  var darkModeNoteColour = const Color(0xffffffff); //black
  var lightModeNoteColour = const Color(0xff000000); //purple

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.notes.noteTitle;
    _textController.text = widget.notes.noteText;
  }

  dynamic themeNoteColour() {
    if (themeSwitch) {
      return darkModeNoteColour;
    } else {
      return lightModeNoteColour;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColour(),
        elevation: 0,
        iconTheme: IconThemeData(
          color: themeFontColour(), //change your color here
        ),
        actions: <Widget>[
          addDeleteIcon(),
          IconButton(
            icon: Icon(
              Icons.save,
            ),
            onPressed: () async {
              widget.notes.noteTitle = _titleController.text;
              widget.notes.noteText = _textController.text;
/*.then(function(docRef) {
    console.log("Document written with ID: ", docRef.id);
})*/
              await db
                  .collection('notes')
                  .add(widget.notes.toJson())
                  .then((DocumentReference dr) {
                print("Document written with ID: " + dr.id);
              });

              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyApp()));
              //get title and text save to db
            },
          ),
        ],
      ),
      resizeToAvoidBottomPadding: false,
      backgroundColor: themeColour(),
      body: new SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.fromLTRB(20.0, 10.0, 15.0, 0),
          child: Column(
            children: [
              addTitle(),
              addText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget addDeleteIcon() {
    return IconButton(
      icon: Icon(
        Icons.delete,
      ),
      onPressed: () async {
        await db.collection('notes').get().then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
          }
        });

        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  Widget addTitle() {
    return TextField(
      maxLines: null,
      controller: _titleController,
      cursorColor: Colors.white,
      style: TextStyle(color: themeFontColour(), fontSize: 23),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Title',
        hintStyle: TextStyle(color: themeFontColour(), fontSize: 23),
      ),
    );
  }

  Widget addText() {
    return Flexible(
      child: TextField(
        maxLines: null,
        controller: _textController,
        cursorColor: Colors.white,
        style: TextStyle(color: themeFontColour(), fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Take note',
          hintStyle: TextStyle(color: themeFontColour(), fontSize: 16),
        ),
      ),
    );
  }
}
