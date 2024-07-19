import 'package:flutter/material.dart';
import 'package:my_class/screens/home_screen.dart';
import 'package:my_class/screens/login.dart';
import 'package:my_class/screens/teacher_home.dart';
import 'package:my_class/services/authentication.dart';
import 'package:my_class/widget/button.dart';
import 'package:my_class/widget/snackbar.dart';
import 'package:my_class/widget/textbox.dart';

// Enum to represent roles
enum UserRole { teacher, student }

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  UserRole? selectedRole;
  bool isLoading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signupUser() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedRole == null) {
      showSnackBar(context, "Please fill in all fields.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    String res = await AuthMethod().signupUser(
      email: emailController.text,
      password: passwordController.text,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      role: selectedRole == UserRole.teacher ? "teacher" : "student",
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (res == "success" && selectedRole == UserRole.student) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else if (res == "success" && selectedRole == UserRole.teacher) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const TeacherHome(),
        ),
      );
    } else {
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFieldInput(
                icon: Icons.person,
                textEditingController: firstNameController,
                hintText: 'First Name',
              ),
              TextFieldInput(
                icon: Icons.person,
                textEditingController: lastNameController,
                hintText: 'Last Name',
              ),
              TextFieldInput(
                icon: Icons.email,
                textEditingController: emailController,
                hintText: 'Enter your email',
              ),
              TextFieldInput(
                icon: Icons.lock,
                textEditingController: passwordController,
                hintText: 'Enter your password',
                isPass: true,
              ),
              ListTile(
                subtitle: Column(
                  children: [
                    RadioListTile<UserRole>(
                      title: const Text('Teacher'),
                      value: UserRole.teacher,
                      groupValue: selectedRole,
                      onChanged: (UserRole? value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                    ),
                    RadioListTile<UserRole>(
                      title: const Text('Student'),
                      value: UserRole.student,
                      groupValue: selectedRole,
                      onChanged: (UserRole? value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              MyButtons(onTap: signupUser, text: "Sign Up"),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      " Login",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              if (isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
