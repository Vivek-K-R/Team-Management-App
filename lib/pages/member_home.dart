// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MemberHome extends StatefulWidget {
  const MemberHome({super.key});

  @override
  State<MemberHome> createState() => _MemberHomeState();
}

class _MemberHomeState extends State<MemberHome> {
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Member HomePage",
            style: TextStyle(
              fontSize: 24, // Larger font size
              fontWeight: FontWeight.bold, // Bold text
              color: Colors.white, // White text for contrast
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 148, 126, 170),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 210, 210, 210),
        child: Column(
          children: [
            DrawerHeader(
                child: Icon(
              Icons.face,
              size: 48,
            )),

            Text(
              user.email!,
              style: TextStyle(
                fontSize: 18, // Larger font size
              ),
            ),

            SizedBox(height: 25),

            //listTile1
            ListTile(
              leading: Icon(Icons.home),
              title: Text("HOME"),
            ),

            //listTile2
            ListTile(
              leading: Icon(Icons.question_mark),
              title: Text("LOGOUT"),
              onTap: signOut,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // MainQuest Details
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/mainquest');
              },
              child: Center(
                child: Container(
                  // width: MediaQuery.of(context).size.width * 0.5, // 50% width
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                        255, 224, 224, 224), // Light grey container background
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage('assets/images/QuestDetails.jpeg'),
                      fit: BoxFit.cover,
                      alignment: Alignment(1.0, 0.94),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Project Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black,
                            offset: Offset(0.0, 2.0),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),

            // Active Quest
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/viewtask');
              },
              child: Center(
                child: Container(
                  // width: MediaQuery.of(context).size.width * 1,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/activequest.gif"),
                      fit: BoxFit.cover,
                      alignment: Alignment(1.0, -0.2),
                    ),
                    color: Colors.grey[300], // Light grey container background
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      "Active Tasks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black,
                            offset: Offset(0.0, 2.0),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),

            // ChatRoom
            Center(
              child: Container(
                // width: MediaQuery.of(context).size.width * 0.5,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Light grey container background
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage('assets/images/teamchat.gif'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/chatroom');
                    },
                    child: Text(
                      "Team Chat",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black,
                            offset: Offset(0.0, 2.0),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),

            // QuestStats
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/stats');
              },
              child: Center(
                child: Container(
                  // width: MediaQuery.of(context).size.width * 0.5,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Light grey container background
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: AssetImage('assets/images/stats.gif'),
                        fit: BoxFit.fitWidth,
                        alignment: Alignment(0.0, 0.0)),
                  ),
                  child: Center(
                    child: Text(
                      "Member Stats",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black,
                            offset: Offset(0.0, 2.0),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
