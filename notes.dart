import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_class/screens/add_note.dart';
import 'package:my_class/screens/note_actions.dart';

class NotesScreen extends StatefulWidget {
  final String classId;

  const NotesScreen({Key? key, required this.classId}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _notesStream;
  late User _currentUser;
  late DocumentReference _currentUserRef;
  bool _isTeacher = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _currentUserRef =
        FirebaseFirestore.instance.collection('users').doc(_currentUser.uid);
    _notesStream = FirebaseFirestore.instance
        .collection('classroom')
        .doc(widget.classId)
        .collection('notes')
        .orderBy('postDate', descending: true)
        .snapshots();

    _checkIfTeacher();
  }

  Future<void> _checkIfTeacher() async {
    DocumentSnapshot classSnapshot = await FirebaseFirestore.instance
        .collection('classroom')
        .doc(widget.classId)
        .get();

    if (classSnapshot.exists) {
      DocumentReference teacherRef = classSnapshot['teacherId'];
      setState(() {
        _isTeacher = teacherRef == _currentUserRef;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _notesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No Notes available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var note = snapshot.data!.docs[index].data();
              var postTime = note['postDate'];
              var attachments = note['noteUrls'] ?? [];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text(note['noteTitle']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note['noteDesc']),
                        SizedBox(height: 8),
                        Text(
                          'Posted on: ${DateFormat('dd MMM yyyy, hh:mm a').format(postTime.toDate())}',
                          style: TextStyle(color: Colors.grey),
                        ),
                        if (attachments.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: attachments.map<Widget>((url) {
                              return Chip(
                                label: Text(url),
                                backgroundColor: Colors.blue,
                              );
                            }).toList(),
                          ),
                        ],
                        SizedBox(height: 8),
                        if (_isTeacher)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  showEditNoteDialog(context, widget.classId,
                                      snapshot.data!.docs[index].id, note);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDeleteNoteDialog(context, widget.classId,
                                      snapshot.data!.docs[index].id);
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _isTeacher
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddNote(
                      classId: widget.classId,
                    ),
                  ),
                );
                print('Add note');
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }
}
