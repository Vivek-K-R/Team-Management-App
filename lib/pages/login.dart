import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:team_man/components/my_button.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //signIn
  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              //Logo
              const Icon(
                Icons.android,
                size: 100,
              ),

              const SizedBox(height: 30),

              //Username Textfield
              TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    enabledBorder: OutlineInputBorder(),
                  )),

              const SizedBox(height: 20),
              //Password textfield
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  enabledBorder: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              //forgot password????
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              //SignIn Button
              const SizedBox(height: 30),
              GestureDetector(
                onTap: signIn,
                child: const MyButton(),
              ),
              //continue with google

              //not a member?
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Not a member? "),
                  GestureDetector(
                    onTap: widget.showRegisterPage,
                    child: const Text(
                      "Register Now",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
