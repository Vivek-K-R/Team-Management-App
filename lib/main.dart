// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:team_man/firebase_options.dart';
import 'package:team_man/pages/chatroom.dart';

// ignore: unused_import
import 'package:team_man/pages/login.dart';
import 'package:team_man/pages/mainquest.dart';
import 'package:team_man/pages/mainquestadd.dart';
import 'package:team_man/pages/member_home.dart';
import 'package:team_man/pages/start_page.dart';
import 'package:team_man/pages/stats.dart';
import 'package:team_man/pages/tasks_leadview.dart';
import 'package:team_man/pages/tasks_memberview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.grey[300],
          body: MainPage(),
          bottomNavigationBar: NavigationBar(destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
            NavigationDestination(icon: Icon(Icons.abc), label: "ABC")
          ])),
      routes: {
        '/mainquest': (context) => MainQuest(),
        '/mainquestadd': (context) => AddMainQuest(),
        '/addtask': (context) => TaskManagementPage(),
        '/memberhome': (context) => MemberHome(),
        '/chatroom': (context) => ChatRoomScreen(),
        '/viewtask': (context) => TaskViewPage(),
        '/stats': (context) => StatisticsPage(),
      },
    );
  }
}
