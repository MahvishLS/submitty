import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_class/screens/joinClass.dart';
import 'package:my_class/screens/login.dart';
import 'package:my_class/screens/sections.dart';
import 'package:my_class/widget/snackbar.dart';
import 'package:my_class/services/authentication.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User _currentUser;
  late Stream<DocumentSnapshot> _userStream;
  final AuthMethod _authMethod = AuthMethod();

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .snapshots();
  }

  // get user's first name
  Future<String> getUserFirstName() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .get();
      String firstName = userSnapshot.get('firstName');
      return firstName;
    } catch (e) {
      showSnackBar(context, 'Error fetching user data: $e');
      return '';
    }
  }

  // to greet user
  Widget greetUser() {
    return FutureBuilder<String>(
      future: getUserFirstName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Hello, Loading...');
        }

        if (snapshot.hasError || !snapshot.hasData) {
          showSnackBar(context, 'Error fetching user name.');
          return const Text('Hello, User');
        }

        String firstName = snapshot.data!;
        return Text('Hello, $firstName');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Classes"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authMethod.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: greetUser(),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _userStream,
              builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                }

                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Center(child: Text('User not found.'));
                }

                List<dynamic>? classList = userSnapshot.data!.get('classList');
                if (classList == null || classList.isEmpty) {
                  return const Center(
                      child: Text('No classes found for this user.'));
                }

                return ListView.builder(
                  itemCount: classList.length,
                  itemBuilder: (context, index) {
                    DocumentReference<Map<String, dynamic>> classRef =
                        classList[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ClassSection(classRef: classRef),
                            ),
                          );
                        },
                        child: FutureBuilder<DocumentSnapshot>(
                          future: classRef.get(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> classSnapshot) {
                            if (classSnapshot.hasError) {
                              return Text('Error: ${classSnapshot.error}');
                            }

                            if (classSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!classSnapshot.hasData ||
                                !classSnapshot.data!.exists) {
                              return const Text('Class not found.');
                            }

                            Map<String, dynamic>? classData =
                                classSnapshot.data!.data()
                                    as Map<String, dynamic>?;

                            print("classData: $classData");

                            String className = classData?['class-name'] ?? '';
                            DocumentReference teacherRef =
                                classData?['teacherId'];

                            // Convert DocumentReference to a String
                            String teacherId = teacherRef.id;

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(teacherId)
                                  .get(),
                              builder: (context,
                                  AsyncSnapshot<DocumentSnapshot>
                                      teacherSnapshot) {
                                if (teacherSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text('Loading...');
                                }

                                if (teacherSnapshot.hasError) {
                                  return Text(
                                      'Error: ${teacherSnapshot.error}');
                                }

                                if (!teacherSnapshot.hasData ||
                                    !teacherSnapshot.data!.exists) {
                                  return const Text('Teacher not found');
                                }

                                String teacherName =
                                    teacherSnapshot.data!.get('fullName');
                                return Container(
                                  color: Colors.lightBlue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 30),
                                  child: Column(
                                    children: [
                                      Text(
                                        className,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 30),
                                      ),
                                      Text(
                                        'Teacher: $teacherName',
                                        style: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 105, 100, 100)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JoinClass(userId: _currentUser.uid),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
