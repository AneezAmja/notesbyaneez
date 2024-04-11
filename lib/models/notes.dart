import 'package:cloud_firestore/cloud_firestore.dart';

class Notes {
  String noteTitle;
  String noteText;

  Notes(
    this.noteTitle,
    this.noteText,
  );

// Formatting data to Firebase
  Map<String, dynamic> toJson() => {
        'title': noteTitle,
        'text': noteText,
      };

// Getting data from Firestore
  Notes.fromFirestore(DocumentSnapshot snapshot)
      : noteTitle = snapshot.data()['title'],
        noteText = snapshot.data()['text'];
}
