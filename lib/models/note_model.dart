import 'package:cloud_firestore/cloud_firestore.dart';

/*
 This file defines a Dart class representing a note, including its title and text content. 
 It includes methods for formatting note data to be stored in Firestore and retrieving 
 note data from Firestore using DocumentSnapshot.

 */
class Notes {
  String noteTitle;
  String noteText;
  String noteId;
  DateTime noteTimestamp;

  Notes(
    this.noteTitle,
    this.noteText,
    this.noteId,
    this.noteTimestamp,
  );

// Formatting data to Firebase
  Map<String, dynamic> toJson() => {
        'title': noteTitle,
        'text': noteText,
        'timestamp': noteTimestamp,
      };

// Getting data from Firestore
  Notes.fromFirestore(DocumentSnapshot snapshot)
      : noteTitle = (snapshot.data() as Map<String, dynamic>?)?['title'] ?? '',
        noteText = (snapshot.data() as Map<String, dynamic>?)?['text'] ?? '',
        noteId = snapshot.id,
        noteTimestamp =
            (snapshot.data() as Map<String, dynamic>?)?['noteTimestamp']
                    ?.toDate() ??
                DateTime.now(); // Parse timestamp from Firestore data
}
