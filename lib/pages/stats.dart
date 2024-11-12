import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Statistics'),
        backgroundColor: Colors.deepPurple[200],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Map to store the count of completed and incomplete tasks for each member
          Map<String, Map<String, int>> memberTaskStats = {};

          for (var taskDoc in snapshot.data!.docs) {
            final taskData = taskDoc.data() as Map<String, dynamic>;
            final memberId = taskData['memberId'] as String;
            final isCompleted = taskData['isCompleted'] as bool;

            // Initialize the member data in the map if it doesn't exist
            memberTaskStats.putIfAbsent(
                memberId,
                () => {
                      'completed': 0,
                      'incomplete': 0,
                    });

            // Increment the appropriate count
            if (isCompleted) {
              memberTaskStats[memberId]!['completed'] =
                  memberTaskStats[memberId]!['completed']! + 1;
            } else {
              memberTaskStats[memberId]!['incomplete'] =
                  memberTaskStats[memberId]!['incomplete']! + 1;
            }
          }

          // Display pie chart for each member
          return ListView.builder(
            itemCount: memberTaskStats.keys.length,
            itemBuilder: (context, index) {
              final memberId = memberTaskStats.keys.elementAt(index);
              final stats = memberTaskStats[memberId]!;

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

                  if (!memberSnapshot.hasData || !memberSnapshot.data!.exists) {
                    return const ListTile(title: Text("Member not found"));
                  }

                  final memberData =
                      memberSnapshot.data!.data() as Map<String, dynamic>;
                  final memberName =
                      "${memberData['fname']} ${memberData['lname']}";

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memberName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: stats['completed']!.toDouble(),
                                  title: 'Completed',
                                  color: Colors.green,
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                PieChartSectionData(
                                  value: stats['incomplete']!.toDouble(),
                                  title: 'Incomplete',
                                  color: Colors.red,
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
