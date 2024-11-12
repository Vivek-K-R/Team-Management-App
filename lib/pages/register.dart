import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:team_man/components/signup_button.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();

  String? _selectedRole; // Variable to store selected role

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    super.dispose();
  }

  Future signUp() async {
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      try {
        // Create user and get the UserCredential
        UserCredential userCred =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Get the user UID
        String uid = userCred.user!.uid;

        // Add user details to Firestore, including the UID
        await addUserDetails(
          uid, // Pass the UID to the method
          _fnameController.text.trim(),
          _lnameController.text.trim(),
          _emailController.text.trim(),
          int.parse(_selectedRole!),
        );

        // Sign out immediately after creating the account and adding details
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Account created successfully! Please login with your credentials.'),
              duration: Duration(seconds: 3),
            ),
          );

          // Short delay to ensure the snackbar is visible before navigation
          await Future.delayed(const Duration(milliseconds: 500));

          // Navigate to login page
          widget.showLoginPage();
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? "Registration failed"),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("An unexpected error occurred"),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select a role"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future addUserDetails(
      String uid, String fname, String lname, String email, int role) async {
    await FirebaseFirestore.instance.collection('users').add({
      'uid': uid, // Add the UID to the document
      'fname': fname,
      'lname': lname,
      'email': email,
      'role': role,
    });
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmPasswordController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Icon(Icons.android, size: 100),
                  const SizedBox(height: 10),
                  const Text("Register below with your details!"),

                  // First Name
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _fnameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      enabledBorder: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),

                  // Last Name
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _lnameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      enabledBorder: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),

                  // Role Dropdown
                  const SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      enabledBorder: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '1',
                        child: Text('Lead'),
                      ),
                      DropdownMenuItem(
                        value: '2',
                        child: Text('Member'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a role' : null,
                  ),

                  // Email
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      enabledBorder: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  // Password
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      enabledBorder: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),

                  // Confirm Password
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      enabledBorder: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: signUp,
                    child: const SignUpButton(),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already signed up? "),
                      GestureDetector(
                        onTap: widget.showLoginPage,
                        child: const Text(
                          "Login now",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
