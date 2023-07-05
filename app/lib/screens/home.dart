import 'package:app/screens/add_student.dart';
import 'package:app/screens/camera_feed.dart';
import 'package:app/screens/students_list.dart';
import 'package:app/screens/todays_attendance.dart';
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

  Widget buildTile({
    required String text,
    required VoidCallback onPress,
    required Widget icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton.icon(
        onPressed: onPress,
        icon: icon,
        label: Text(text),
      ),
    );
    // return Material(
    //   color: Colors.transparent,
    //   child: InkWell(
    //     onTap: onPress,
    //     child: Container(
    //       padding: const EdgeInsets.all(10),
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(10),
    //         boxShadow: const [
    //           BoxShadow(
    //             color: Colors.grey,
    //             blurRadius: 1,
    //             blurStyle: BlurStyle.outer,
    //             offset: Offset(1, 1),
    //           ),
    //         ],
    //       ),
    //       child: Text(
    //         text,
    //         style: Theme.of(context).textTheme.headlineSmall,
    //       ),
    //     ),
    //   ),
    // );
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
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTile(
                text: "Scan Students",
                icon: const Icon(Icons.camera),
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => FeedPage(
                        cameras: cameras,
                      ),
                    ),
                  );
                },
              ),
              buildTile(
                text: "View Today's Attendance",
                icon: const Icon(Icons.person),
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const TodaysAttendancePage(),
                    ),
                  );
                },
              ),
              buildTile(
                text: "View Students",
                icon: const Icon(Icons.list),
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const StudentsList(),
                    ),
                  );
                },
              ),
              buildTile(
                text: "Add Student",
                icon: const Icon(Icons.add),
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const AddStudentPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
