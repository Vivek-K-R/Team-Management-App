import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainQuest extends StatefulWidget {
  @override
  _MainQuestState createState() => _MainQuestState();
}

class _MainQuestState extends State<MainQuest> {
  String? selectedTitle;
  List<Map<String, dynamic>> projects = [];

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('projects').get();
    setState(() {
      projects = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Projects Details"),
        backgroundColor: Colors.deepPurple[200],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<String>(
                hint: const Text("Select a project"),
                value: selectedTitle,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTitle = newValue;
                  });
                },
                items: projects.map((project) {
                  return DropdownMenuItem<String>(
                    value: project['title'],
                    child: Text(project['title']),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              if (selectedTitle != null) ...[
                // Find the selected project
                ...projects
                    .where((project) => project['title'] == selectedTitle)
                    .map((project) {
                  return Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project['title'],
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          project['description'],
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
