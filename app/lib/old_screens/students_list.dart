import 'package:app/models/firebase_data_manager.dart';
import 'package:app/old_widgets/student_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/student.dart';

class StudentsList extends StatefulWidget {
  const StudentsList({super.key});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  final Stream<QuerySnapshot> studentsStream =
      FirebaseFirestore.instance.collection("students").snapshots();

  void deleteStudent(Student student) async {
    // delete student and all related data (including student image)
    FirebaseDataManager.deleteStudentById(student.studentID!);

    // notify user via snackbar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Deleted student"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: studentsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text("Loading..."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => StudentListItem(
              student: Student(
                studentID: snapshot.data!.docs[index].id,
                user: snapshot.data!.docs[index]["user"],
                firstName: snapshot.data!.docs[index]["firstName"],
                lastName: snapshot.data!.docs[index]["lastName"],
                primaryContact: snapshot.data!.docs[index]["primaryContact"],
                secondaryContact: snapshot.data!.docs[index]
                    ["secondaryContact"],
                embeddings: snapshot.data!.docs[index]["embeddings"],
                imgUrl: snapshot.data!.docs[index]["imgUrl"],
              ),
            ),
          );
        },
      ),
    );
  }
}
