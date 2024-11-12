import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMainQuest extends StatefulWidget {
  const AddMainQuest({super.key});

  @override
  State<AddMainQuest> createState() => _AddMainQuestState();
}

class _AddMainQuestState extends State<AddMainQuest> {
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _headingController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

// Inside your _AddMainQuestState class
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Details'),
        backgroundColor: Colors.deepPurple[200],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _headingController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String title = _headingController.text;
                String description = _descriptionController.text;

                // Create a document in Firestore
                await FirebaseFirestore.instance.collection('projects').add({
                  'title': title,
                  'description': description,
                  // 'createdAt':
                  //     FieldValue.serverTimestamp(), // Optional: Timestamp
                });

                // Optionally, clear the text fields after submission
                _headingController.clear();
                _descriptionController.clear();

                // Print to console (optional)
                print('Heading: $title');
                print('Description: $description');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[200],
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
