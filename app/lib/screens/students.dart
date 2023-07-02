import 'package:app/auth.dart';
import 'package:app/widgets/student_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../classes/student.dart';

class StudentsList extends StatefulWidget {
  const StudentsList({super.key});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  List<Student> students = [];
  bool loadingStudents = true;

  getStudents() {
    FirebaseFirestore.instance
        .collection("students")
        .where("user", isEqualTo: Auth().currentUser?.email)
        .get()
        .then(
      (QuerySnapshot querySnapshot) {
        setState(() {
          students = querySnapshot.docs.map((docSnapshot) {
            final Map<String, dynamic> data =
                docSnapshot.data() as Map<String, dynamic>;

            return Student(
              user: data["user"],
              firstName: data["firstName"],
              lastName: data["lastName"],
              primaryContact: data["primaryContact"],
              secondaryContact: data["secondaryContact"],
              studentID: docSnapshot.id,
            );
          }).toList();
          loadingStudents = false;
        });
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  @override
  void initState() {
    getStudents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students"),
      ),
      body: loadingStudents
          ? const Center(
              child: Text("Loading..."),
            )
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (ctx, index) {
                return StudentListItem(
                  student: students[index],
                );
              },
            ),
    );
  }
}
