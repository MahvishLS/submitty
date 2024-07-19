import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatefulWidget {
  final String classId;

  const AnnouncementsScreen({Key? key, required this.classId})
      : super(key: key);

  @override
  _AnnouncementsScreenState createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _announcementsStream;

  @override
  void initState() {
    super.initState();
    _announcementsStream = FirebaseFirestore.instance
        .collection('classroom')
        .doc(widget.classId)
        .collection('announcements')
        .orderBy('postDate', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _announcementsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No announcements available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var announcement = snapshot.data!.docs[index].data();
              var postDate = announcement['postDate'];
              var attachments = announcement['attachments'] ?? [];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text(announcement['announcementTitle']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(announcement['announcementBody']),
                        SizedBox(height: 8),
                        Text(
                          'Posted on: ${DateFormat('dd MMM yyyy, hh:mm a').format(postDate.toDate())}',
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
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
