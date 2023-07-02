import 'package:app/screens/add_student.dart';
import 'package:app/screens/camera_feed.dart';
import 'package:app/screens/students_list.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:app/models/auth.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({
    super.key,
    required this.title,
    required this.cameras,
  });

  final String title;
  final List<CameraDescription> cameras;
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget buildUserUid() {
    return Text(user?.email ?? "User email");
  }

  Widget buildSignOutButton() {
    return TextButton(
      onPressed: signOut,
      child: const Text("Sign Out"),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Text(
        "AttendEase",
        style: Theme.of(context).textTheme.headlineLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildFeedPageButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => FeedPage(
              cameras: cameras,
            ),
          ),
        );
      },
      child: const Text("Scan"),
    );
  }

  Widget buildSeeStudentsButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => const StudentsList(),
          ),
        );
      },
      child: const Text("See Students"),
    );
  }

  Widget buildAddStudentButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => const AddStudentPage(),
          ),
        );
      },
      child: const Text("Add Student"),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Signed in as:",
                  style: Theme.of(context).textTheme.bodySmall),
              Text("${user?.email}",
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          buildSignOutButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildTitle(context),
              buildFeedPageButton(context),
              buildSeeStudentsButton(context),
              buildAddStudentButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
