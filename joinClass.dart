import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_class/widget/button.dart';
import 'package:my_class/widget/snackbar.dart';
import 'package:my_class/widget/textbox.dart';

class JoinClass extends StatefulWidget {
  final String userId;

  const JoinClass({Key? key, required this.userId}) : super(key: key);

  @override
  _JoinClassState createState() => _JoinClassState();
}

class _JoinClassState extends State<JoinClass> {
  final TextEditingController _classIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> joinClass() async {
    setState(() {
      _isLoading = true;
    });

    String classId = _classIdController.text.trim();
    if (classId.isEmpty) {
      showSnackBar(context, "Class Id cannot be empty");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      DocumentReference classRef =
          FirebaseFirestore.instance.collection('classroom').doc(classId);

      // Check if classId exists
      DocumentSnapshot classSnapshot = await classRef.get();
      if (!classSnapshot.exists) {
        showSnackBar(context, "Invalid Class Id");
        setState(() {
          _isLoading = false;
        });
        return;
      }

// Add class reference to user's classList array
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'classList': FieldValue.arrayUnion([classRef]),
      });

      // Add userId to class's student array
      // await classRef.update({
      //   'students': FieldValue.arrayUnion([widget.userId]),
      // });

      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(widget.userId);

// Add user reference to class's student array
      await classRef.update({
        'students': FieldValue.arrayUnion([userRef]),
      });

      showSnackBar(context, "Successfully joined the class");
      Navigator.of(context).pop();
    } catch (e) {
      showSnackBar(context, 'Error joining class: $e');
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
        title: const Text('Join Class'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFieldInput(
              textEditingController: _classIdController,
              hintText: 'Enter Class ID',
              icon: Icons.book,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : MyButtons(
                    text: 'Join Class',
                    onTap: joinClass,
                  ),
          ],
        ),
      ),
    );
  }
}
