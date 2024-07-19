import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showEditNoteDialog(BuildContext context, String classId, String noteId,
    Map<String, dynamic> note) {
  final TextEditingController titleController =
      TextEditingController(text: note['noteTitle']);
  final TextEditingController descController =
      TextEditingController(text: note['noteDesc']);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: 'Description'),
              maxLines: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('classroom')
                  .doc(classId)
                  .collection('notes')
                  .doc(noteId)
                  .update({
                'noteTitle': titleController.text,
                'noteDesc': descController.text,
                'postDate': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

void showDeleteNoteDialog(BuildContext context, String classId, String noteId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('classroom')
                  .doc(classId)
                  .collection('notes')
                  .doc(noteId)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
