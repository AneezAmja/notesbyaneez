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

var darkMode = const Color(0xff121212); //dark grey
var darkModeFontColour = const Color(0xffBB86FC); //purple
var darkModeCardColour = const Color(0xff1c1c1c); //lighter dark grey

var lightMode = const Color(0xffffffff); //white
var lightModeFontColour = const Color(0xff000000); //black
var lightModeCardColour = const Color(0xffffffff); //white

bool themeSwitch = false;

dynamic themeColour() {
  if (themeSwitch) {
    return darkMode;
  } else {
    return lightMode;
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
  var primaryColour = const Color(0xffd03056);
  var secondaryColour = const Color(0xff791C31);
  var tertiaryColour = const Color(0xff333534);

  @override
  void initState() {
    super.initState();
    // Firebase.initializeApp().whenComplete(() {
    //   print("completed");
    //   setState(() {});
    // });
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
      margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
      color: themeCardColour(),
      elevation: 10.0,
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.all(new Radius.circular(10.0))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
        child: InkWell(
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0, 8.0),
                  child: Text(
                    data['title'] ?? "",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                        color: themeFontColour()),
                  ),
                ),
                Text(
                  data['text'] ?? "",
                  style: TextStyle(
                      fontSize: 15,
                      color: themeFontColour(),
                      overflow: TextOverflow.ellipsis),
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: themeFontColour()));
    return Scaffold(
      appBar: AppBar(
        elevation: 15.0,
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
                      fontStyle: FontStyle.normal,
                      fontSize: 18),
                ),
                TextSpan(
                  text: 'by Aneez',
                  style: TextStyle(
                      color: themeFontColour(),
                      fontStyle: FontStyle.italic,
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
              return ListView.builder(
                itemCount: snapshot
                    .data!.docs.length, // Access docs instead of documents
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
      floatingActionButton: createNote(),
    );
  }

  Widget createNote() {
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
        "Add note",
        style: TextStyle(color: themeFontColour()),
      ),
      icon: Icon(
        Icons.add,
        color: themeFontColour(),
      ),
      elevation: 15.0,
    );
  }
}
