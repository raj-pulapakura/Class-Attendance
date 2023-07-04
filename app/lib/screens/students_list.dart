import 'package:app/models/firebase_data_manager.dart';
import 'package:app/screens/student_view.dart';
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

  Widget buildStudentListItem(Student student) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return StudentView(student: student);
          }),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          color: Colors.grey[100],
          boxShadow: const [
            BoxShadow(
              blurRadius: 2,
              blurStyle: BlurStyle.outer,
              color: Colors.grey,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (student.imgUrl != null)
              Container(
                margin: const EdgeInsets.only(right: 20),
                child: Hero(
                  tag: "${student.studentID!}-image",
                  child: Image.network(
                    student.imgUrl!,
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: "${student.studentID!}-fullname",
                  child: Text(
                    "${student.firstName} ${student.lastName}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Text("Primary contact: ${student.primaryContact}"),
              ],
            ),
          ],
        ),
      ),
    );
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
            itemBuilder: (ctx, index) => buildStudentListItem(
              Student(
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
