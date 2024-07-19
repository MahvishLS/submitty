import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_class/screens/notes.dart';
import 'announcements.dart';

class ClassSection extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> classRef;

  const ClassSection({
    Key? key,
    required this.classRef,
  }) : super(key: key);

  @override
  _ClassSectionState createState() => _ClassSectionState();
}

class _ClassSectionState extends State<ClassSection> {
  String className = '';
  late String classId;

  @override
  void initState() {
    super.initState();
    classId = widget.classRef.id;
    fetchClassName();
  }

  void fetchClassName() {
    widget.classRef
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        setState(() {
          className = snapshot.data()!['class-name'];
        });
      } else {
        setState(() {
          className = 'My class';
        });
      }
    }).catchError((error) {
      setState(() {
        className = 'Error';
      });
      print('Error fetching class name: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(className.isEmpty ? '' : className),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Announcements'),
              Tab(text: 'Notes'),
              Tab(text: 'Assignments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AnnouncementsScreen(classId: classId),
            NotesScreen(classId: classId),
            const Center(child: Text('Assignments')),
          ],
        ),
      ),
    );
  }
}
