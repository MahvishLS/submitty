import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_class/widget/button.dart';
import 'package:my_class/widget/textbox.dart';

class AddNote extends StatefulWidget {
  final String classId;

  const AddNote({Key? key, required this.classId}) : super(key: key);

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addNote() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      DocumentReference classRef = FirebaseFirestore.instance
          .collection('classroom')
          .doc(widget.classId);

      await classRef.collection('notes').add({
        'noteTitle': titleController.text,
        'noteDesc': descController.text,
        'noteUrls': [],
        'postDate': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note added successfully')),
      );

      Navigator.of(context).pop();
    } catch (err) {
      print('Error adding note: $err');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding note')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
      ),
      body: Center(
        child: Column(
          children: [
            TextFieldInput(
              hintText: "Title",
              icon: Icons.title,
              textEditingController: titleController,
            ),
            TextFieldInput(
              hintText: "Add a description",
              icon: Icons.description,
              textEditingController: descController,
              maxLines: null,
            ),
            _isLoading
                ? CircularProgressIndicator()
                : MyButtons(text: "POST", onTap: _addNote),
          ],
        ),
      ),
    );
  }
}
