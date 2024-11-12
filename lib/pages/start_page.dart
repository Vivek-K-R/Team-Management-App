import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:team_man/pages/authpage.dart';
import 'package:team_man/pages/lead_home.dart';
import 'package:team_man/pages/member_home.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  Future<Widget> _getHomePageBasedOnRole(String email) async {
    try {
      // Fetch the user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get()
          .then((snapshot) => snapshot.docs.first);

      // Get the 'role' field from the user document
      int role = userDoc['role'];

      // Return the appropriate home page based on the role
      if (role == 1) {
        return LeadHome(); // For lead users
      } else if (role == 2) {
        return MemberHome(); // For member users
      } else {
        return const AuthPage(); // If role is not recognized
      }
    } catch (e) {
      // Handle case where user document is not found or another error occurs
      print("Error fetching user role: $e");
      return const AuthPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final email = snapshot.data?.email;

            if (email != null) {
              // While fetching the home page based on role, show a loading indicator
              return FutureBuilder<Widget>(
                future: _getHomePageBasedOnRole(email),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (roleSnapshot.hasError) {
                    return const Center(child: Text("Error loading role"));
                  } else {
                    // Once the role is determined, navigate to the appropriate home page
                    return roleSnapshot.data!;
                  }
                },
              );
            } else {
              return const AuthPage(); // Fallback if email is null
            }
          } else {
            return const AuthPage(); // If user is not signed in
          }
        },
      ),
    );
  }
}
