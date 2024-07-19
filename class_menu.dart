import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassMenu extends StatelessWidget {
  final String classId;
  final Function onViewStudents;

  const ClassMenu({
    Key? key,
    required this.classId,
    required this.onViewStudents,
  }) : super(key: key);

  Future<void> deleteClass(BuildContext context) async {
    try {
      DocumentReference classRef =
          FirebaseFirestore.instance.collection('classroom').doc(classId);

      DocumentSnapshot classSnapshot = await classRef.get();

      if (!classSnapshot.exists) {
        throw Exception("Class not found");
      }

      // Get the list of student references and teacher reference from the class document
      List<dynamic> students = classSnapshot['students'];
      DocumentReference teacherRef = classSnapshot['teacherId'];
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var studentRef in students) {
        if (studentRef is DocumentReference) {
          batch.update(studentRef, {
            'classList': FieldValue.arrayRemove([classRef]),
          });
        } else {
          print('Invalid student reference: $studentRef');
        }
      }

      // Remove the class reference from the teacher's classList array
      batch.update(teacherRef, {
        'classList': FieldValue.arrayRemove([classRef]),
      });

      // Delete the class document
      batch.delete(classRef);

      // Commit the batch
      await batch.commit();

      Navigator.of(context)
          .pop(); // Close the dialog if class deletion is successful

      print('Class deleted successfully');
    } catch (e) {
      print('Error deleting class: $e');
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Class'),
          content: const Text(
              'Are you sure you want to delete this class? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                deleteClass(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        switch (value) {
          case 'share':
            Clipboard.setData(ClipboardData(text: classId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Class ID copied to clipboard')),
            );
            break;
          case 'viewStudents':
            onViewStudents();
            break;
          case 'deleteClass':
            _showDeleteConfirmationDialog(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'share',
            child: Text('Get Class ID to Share'),
          ),
          const PopupMenuItem<String>(
            value: 'viewStudents',
            child: Text('See Students List'),
          ),
          const PopupMenuItem<String>(
            value: 'deleteClass',
            child: Text(
              'Delete this class',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ];
      },
    );
  }
}
