import 'package:aneez_notes/main.dart';
import 'package:aneez_notes/models/note_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/* 
 This file defines a Flutter widget for creating and editing notes. 
 It includes functionality for saving notes to Firestore, deleting notes, 
 and customizing note appearance based on the app's theme settings.
*/

class Note extends StatefulWidget {
  final Notes notes;

  Note({Key? key, required this.notes}) : super(key: key);

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
    if (widget.notes.noteId.isEmpty) {
      _titleController.text = '';
      _textController.text = '';
    } else {
      _titleController.text = widget.notes.noteTitle;
      _textController.text = widget.notes.noteText;
    }
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
        actions: <Widget>[deleteNote(), saveNote()],
      ),
      backgroundColor: themeColour(),
      body: new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: AlwaysScrollableScrollPhysics(),
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.fromLTRB(20.0, 10.0, 15.0, 0),
          child: Column(
            children: [
              writeNoteTitle(),
              writeNoteText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget saveNote() {
    return IconButton(
      icon: Icon(
        Icons.save,
      ),
      onPressed: () async {
        widget.notes.noteTitle = _titleController.text;
        widget.notes.noteText = _textController.text;

        if (widget.notes.noteId.isNotEmpty) {
          // Update existing note
          try {
            await db
                .collection('notes')
                .doc(widget.notes.noteId)
                .update(widget.notes.toJson());

            // Navigate back to the previous screen
            Navigator.pop(context);
          } catch (e) {
            print('Error updating note: $e');
          }
        } else {
          // Create new note
          try {
            await db.collection('notes').add(widget.notes.toJson());

            // Navigate back to the home screen
            Navigator.pop(context);
          } catch (e) {
            print('Error creating note: $e');
          }
        }
      },
    );
  }

  Widget deleteNote() {
    return IconButton(
      icon: Icon(
        Icons.delete,
      ),
      onPressed: () async {
        try {
          // Get the ID of the current note
          String noteId = widget.notes.noteId;

          // Create a reference to the document with the current note's ID
          DocumentReference docRef = db.collection('notes').doc(noteId);

          // Delete the document
          await docRef.delete();

          // Navigate back to the previous screen
          Navigator.of(context).pop();
        } catch (e) {
          print('Error deleting note: $e');
        }

        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  Widget writeNoteTitle() {
    return TextField(
      maxLines: null,
      controller: _titleController,
      cursorColor: themeFontColour(),
      style: TextStyle(
          color: themeFontColour(),
          fontSize: 23,
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Title',
        hintStyle: TextStyle(
          color: themeFontColour().withOpacity(0.3),
          fontSize: 23,
        ),
      ),
    );
  }

  Widget writeNoteText() {
    return Flexible(
      child: TextField(
        maxLines: null,
        controller: _textController,
        cursorColor: themeFontColour(),
        style: TextStyle(
          color: themeFontColour(),
          fontSize: 16,
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Let your notes run wild',
          hintStyle: TextStyle(
              color: themeFontColour().withOpacity(0.3), fontSize: 16),
        ),
      ),
    );
  }
}
