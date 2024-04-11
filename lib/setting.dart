// import 'package:aneez_notes/main.dart';
// import 'package:flutter/material.dart';

// class Setting extends StatefulWidget {
//   @override
//   _SettingState createState() => _SettingState();
// }

// class _SettingState extends State<Setting> {
//   var primaryColour = const Color(0xffd03056);

//   bool state = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: primaryColour,
//           centerTitle: true,
//           title: Center(
//               child: Text(
//             "Settings",
//           )),
//         ),
//         body: Column(
//           children: <Widget>[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(padding: EdgeInsets.fromLTRB(30.0, 100.0, 0, 0)),
//                 Text(
//                   "Dark mode?",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 Switch(
//                   inactiveTrackColor: Colors.yellow,
//                   activeColor: Color(0x666666),
//                   value: state,
//                   onChanged: (bool s) {
//                     setState(() {
//                       state = s;
//                       print(state);
//                     });
//                   },
//                 )
//               ],
//             )
//           ],
//         ));
//   }
// }
