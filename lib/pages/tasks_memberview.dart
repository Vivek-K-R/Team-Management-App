import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskViewPage extends StatefulWidget {
  const TaskViewPage({super.key});

  @override
  State<TaskViewPage> createState() => _TaskViewPageState();
}

class _TaskViewPageState extends State<TaskViewPage> {
  final String? loggedInUserId = FirebaseAuth.instance.currentUser?.uid;

  Future<String?> getUserIdFromMemberId(String memberId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(memberId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? userId = userData['uid'] as String?;
        return userId;
      }
      return null;
    } catch (e) {
      print('Error getting userId: $e');
      return null;
    }
  }

  String getTimeRemaining(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inDays > 1) {
      return "${difference.inDays} days remaining";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hours remaining";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minutes remaining";
    } else {
      return "Deadline is today!";
    }
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
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
                final memberId = task['memberId'] as String;
                final deadlineTimestamp = task['deadline'] as Timestamp?;
                final deadlineDate = deadlineTimestamp != null
                    ? deadlineTimestamp.toDate()
                    : null;

                bool isDeadlinePassed = false;
                String deadlineText = 'No deadline';
                String timeRemainingText = '';

                if (deadlineDate != null) {
                  final today = DateTime.now();
                  isDeadlinePassed = deadlineDate.isBefore(today) &&
                      !DateUtils.isSameDay(deadlineDate, today);
                  deadlineText = DateFormat('MMM d, yyyy').format(deadlineDate);
                  timeRemainingText = isDeadlinePassed
                      ? "Deadline passed"
                      : getTimeRemaining(deadlineDate);
                }

                return FutureBuilder<String?>(
                  future: getUserIdFromMemberId(memberId),
                  builder: (context, userIdSnapshot) {
                    if (userIdSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const ListTile(
                          title: Text("Loading user info..."));
                    }

                    final userId = userIdSnapshot.data;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(memberId)
                          .get(),
                      builder: (context, memberSnapshot) {
                        if (memberSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                              title: Text("Loading member info..."));
                        }

                        if (!memberSnapshot.hasData ||
                            !memberSnapshot.data!.exists) {
                          return const ListTile(
                              title: Text("Member not found"));
                        }

                        final memberData =
                            memberSnapshot.data!.data() as Map<String, dynamic>;
                        final memberName =
                            "${memberData['fname']} ${memberData['lname']}";

                        final isAssignedUser = userId == loggedInUserId;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(
                              task['task'],
                              style: TextStyle(
                                decoration: task['isCompleted']
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Assigned to: $memberName'),
                                Text(
                                  'Deadline: $deadlineText',
                                  style: TextStyle(
                                    color: isDeadlinePassed
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  timeRemainingText,
                                  style: TextStyle(
                                    color: isDeadlinePassed
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            leading: Checkbox(
                              value: task['isCompleted'],
                              onChanged: (bool? value) {
                                if (isAssignedUser) {
                                  toggleTaskStatus(
                                      task.id, task['isCompleted']);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'You are not authorized to check off this task.'),
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Colors.grey,
                                    ),
                                  );
                                  print("Logged In: $loggedInUserId");
                                  print("User ID: $userId");
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'isCompleted': !currentStatus,
    });
  }
}
