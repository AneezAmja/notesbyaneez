import 'package:aneez_notes/models/note_model.dart';
import 'package:aneez_notes/note.dart';
// import 'package:aneez_notes/setting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: '${dotenv.env['API_KEY']}',
    appId: '${dotenv.env['APP_ID']}',
    messagingSenderId: 'sendid',
    projectId: '${dotenv.env['PROJECT_ID']}',
    storageBucket: '${dotenv.env['STORAGE_BUCKET']}',
  ));

  runApp(MaterialApp(
    title: "NotesbyAneez",
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

// var darkMode = const Color(0xff18191b);
var darkModeBackgroundColour = const Color(0xff18191b);
var darkModeFontColour = const Color(0xfffbfbfb);
var darkModeCardColour = const Color(0xff1c1c1c);

var lightModeBackgroundColour = const Color(0xffefeff1);
var lightModeFontColour = const Color(0xff232629);
var lightModeCardColour = const Color(0xffcddaef);

bool themeSwitch = false;

dynamic themeColour() {
  if (themeSwitch) {
    return darkModeBackgroundColour;
  } else {
    return lightModeBackgroundColour;
  }
}

dynamic themeFontColour() {
  if (themeSwitch) {
    return darkModeFontColour;
  } else {
    return lightModeFontColour;
  }
}

dynamic themeCardColour() {
  if (themeSwitch) {
    return darkModeCardColour;
  } else {
    return lightModeCardColour;
  }
}

class MyAppState extends State<MyApp> {
  // var primaryColour = const Color(0xffd03056);
  // var secondaryColour = const Color(0xff791C31);
  // var tertiaryColour = const Color(0xff333534);

  @override
  void initState() {
    super.initState();
    // Firebase.initializeApp().whenComplete(() {
    //   print("completed");
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: themeColour()));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColour(),
        centerTitle: true,
        title: Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Notes ',
                  style: TextStyle(
                      color: themeFontColour(),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                TextSpan(
                  text: 'by Aneez',
                  style: TextStyle(
                      color: themeFontColour(),
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: themeSwitch
                ? Icon(
                    Icons.wb_sunny,
                    color: themeFontColour(),
                  )
                : Icon(Icons.brightness_3, color: themeFontColour()),
            onPressed: () {
              setState(() {
                themeSwitch = !themeSwitch;
              });
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        color: themeColour(),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // or any other loading indicator
            }

            // Ensure snapshot.data is not null before accessing documents
            if (snapshot.data != null) {
              return GridView.builder(
                // creates items lazily as they are scrolled into view
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0, // Spacing between col
                  mainAxisSpacing: 8.0, // Spacing between rows
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) =>
                    buildNotes(context, snapshot.data!.docs[index]),
              );
            } else {
              return Text(
                  'No data available'); // Handle case when snapshot.data is null
            }
          },
        ),
      ),
      floatingActionButton: createNoteFloatingButton(),
    );
  }

  Widget buildNotes(BuildContext context, DocumentSnapshot document) {
    if (!document.exists) {
      // Handle null or non-existent document
      return SizedBox();
    }

    //Getting the note's data from Firestore and saving it as a variable
    final note = Notes.fromFirestore(document);

    final data =
        document.data() as Map<String, dynamic>?; // Cast to the correct type

    if (data == null) {
      // Handle the case when data is null
      return SizedBox();
    }

    return Card(
      // margin: EdgeInsets.fromLTRB(6, 0, 6, 0),
      color: themeCardColour(),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.all(new Radius.circular(10.0))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(3.0, 8.0, 3.0, 8.0),
        child: InkWell(
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                  child: Text(
                    data['title'] ?? "",
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: themeFontColour()),
                  ),
                ),
                Text(
                  data['text'] ?? "",
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: themeFontColour(),
                  ),
                )
              ],
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Note(notes: note)));
            },
          ),
        ),
      ),
    );
  }

  Widget createNoteFloatingButton() {
    Notes tempNote = Notes('', '', '', DateTime.now());
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Note(
                      notes: tempNote,
                    )));
      },
      backgroundColor: themeCardColour(),
      label: Text(
        "Create note",
        style: TextStyle(color: themeFontColour(), fontFamily: 'Inter'),
      ),
      icon: Icon(
        Icons.add,
        color: themeFontColour(),
      ),
      elevation: 5.0,
    );
  }
}
