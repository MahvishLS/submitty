import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentsList extends StatelessWidget {
  final String classId;

  const StudentsList({
    Key? key,
    required this.classId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students List'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classroom')
            .doc(classId)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No students found.'));
          }

          List<dynamic> students = snapshot.data!.get('students');
          print(students);
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              DocumentReference studentRef = students[index];
              return FutureBuilder<DocumentSnapshot>(
                future: studentRef.get(),
                builder:
                    (context, AsyncSnapshot<DocumentSnapshot> studentSnapshot) {
                  if (studentSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  if (studentSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error: ${studentSnapshot.error}'),
                    );
                  }

                  if (!studentSnapshot.hasData ||
                      !studentSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text('Student not found'),
                    );
                  }

                  String studentName = studentSnapshot.data!.get('fullName');
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListTile(
                      title: Text(studentName),
                      titleAlignment: ListTileTitleAlignment.center,
                      tileColor: Colors.grey,
                      selectedTileColor: Colors.lightBlue,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
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
