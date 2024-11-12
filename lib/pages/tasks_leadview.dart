import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskManagementPage extends StatefulWidget {
  const TaskManagementPage({super.key});

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  String? selectedMemberId;
  String? selectedMemberName;
  final _taskController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  // Function to open date picker for deadline
  Future<void> _pickDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  // Function to add a new task with deadline
  Future<void> addTask(String memberId, String memberName) async {
    if (_taskController.text.isEmpty || _selectedDeadline == null) return;

    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'memberId': memberId,
        'memberName': memberName,
        'task': _taskController.text,
        'isCompleted': false,
        'createdAt': Timestamp.now(),
        'createdBy': FirebaseAuth.instance.currentUser?.email,
        'deadline': _selectedDeadline,
      });

      _taskController.clear();
      setState(() {
        _selectedDeadline = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding task: $e')),
        );
      }
    }
  }

  // Function to toggle task completion
  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        backgroundColor: Colors.deepPurple[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Member Selection Dropdown
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 2)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Text("Loading members..."));
                }

                List<DropdownMenuItem<String>> memberItems = [];
                memberItems.add(const DropdownMenuItem(
                  value: "",
                  child: Text("All Members"),
                ));

                for (var doc in snapshot.data!.docs) {
                  memberItems.add(DropdownMenuItem(
                    value: doc.id,
                    child: Text("${doc['fname']} ${doc['lname']}"),
                  ));
                }

                return DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: 'Select Member',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedMemberId,
                  items: memberItems,
                  onChanged: (value) {
                    setState(() {
                      selectedMemberId = value as String?;
                      if (value != null && value.isNotEmpty) {
                        var member = snapshot.data!.docs
                            .firstWhere((doc) => doc.id == value);
                        selectedMemberName =
                            "${member['fname']} ${member['lname']}";
                      }
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // Add Task Section
            if (selectedMemberId != null && selectedMemberId!.isNotEmpty)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          decoration: const InputDecoration(
                            labelText: 'New Task',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () =>
                            addTask(selectedMemberId!, selectedMemberName!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[200],
                          padding: const EdgeInsets.all(8),
                        ),
                        child: const Text(
                          'Add Task',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDeadline != null
                              ? 'Deadline: ${DateFormat.yMd().format(_selectedDeadline!)}'
                              : 'No deadline selected',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _pickDeadline(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[200],
                        ),
                        child: const Text('Pick Deadline'),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Tasks List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedMemberId != null && selectedMemberId!.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection('tasks')
                        .where('memberId', isEqualTo: selectedMemberId)
                        .orderBy('createdAt', descending: true)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('tasks')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text('Loading tasks...'));
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No tasks found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final task = snapshot.data!.docs[index];
                      final deadline =
                          (task['deadline'] as Timestamp?)?.toDate();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task['task'],
                                style: TextStyle(
                                  decoration: task['isCompleted']
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task['isCompleted']
                                    ? 'Status: Completed'
                                    : 'Status: Incomplete',
                                style: TextStyle(
                                  color: task['isCompleted']
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (deadline != null)
                                Text(
                                  'Deadline: ${DateFormat.yMd().format(deadline)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text('Assigned to: ${task['memberName']}'),
                          leading: Icon(
                            task['isCompleted']
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: task['isCompleted']
                                ? Colors.green
                                : Colors.grey,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('tasks')
                                  .doc(task.id)
                                  .delete();
                            },
                          ),
                          onTap: () =>
                              toggleTaskStatus(task.id, task['isCompleted']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
