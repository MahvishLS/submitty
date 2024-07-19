import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_class/widget/button.dart';
import 'package:my_class/widget/textbox.dart';
import 'package:my_class/widget/snackbar.dart';

class CreateClass extends StatefulWidget {
  final String userId;
  const CreateClass({Key? key, required this.userId}) : super(key: key);

  @override
  State<CreateClass> createState() => _CreateClassState();
}

class _CreateClassState extends State<CreateClass> {
  bool _isLoading = false;
  final TextEditingController classNameController = TextEditingController();

  Future<void> createClass() async {
    if (classNameController.text.isEmpty) {
      showSnackBar(context, 'Class name cannot be empty');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      DocumentReference<Map<String, dynamic>> classRef =
          FirebaseFirestore.instance.collection('classroom').doc();

      await classRef.set({
        'class-name': classNameController.text,
        'teacherId':
            FirebaseFirestore.instance.collection('users').doc(widget.userId),
        'students': [],
      });

      // Initialize subcollections with empty documents
      await classRef.collection('assignments').add({});
      await classRef.collection('notes').add({});
      await classRef.collection('announcements').add({});

      // Add classId to the user's classList array
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'classList': FieldValue.arrayUnion([classRef]),
      });

      showSnackBar(context, 'Class created successfully');
    } catch (e) {
      showSnackBar(context, 'Error creating class: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Class"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFieldInput(
              icon: Icons.create_rounded,
              hintText: "Enter class name",
              textEditingController: classNameController,
            ),
            const SizedBox(height: 20),
            MyButtons(
              onTap: createClass,
              text: _isLoading ? 'Creating...' : "Create a New Class",
            ),
          ],
        ),
      ),
    );
  }
}
