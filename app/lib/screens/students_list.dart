import 'package:app/models/firebase_data_manager.dart';
import 'package:flutter/material.dart';

import '../models/student.dart';

class StudentsList extends StatefulWidget {
  const StudentsList({super.key});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  List<Student> students = [];
  bool loadingStudents = true;

  @override
  void initState() {
    getStudents();
    super.initState();
  }

  void getStudents() {
    FirebaseDataManager.getAllStudents().then((fetchedStudents) {
      setState(() {
        students = fetchedStudents.toList();
        loadingStudents = false;
      });
    });
  }

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

    // refresh state to new list of students
    getStudents();
  }

  Widget buildStudentListItemDeleteButton(Student student) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "Are you sure you want to delete the record for ${student.firstName} ${student.lastName}?"),
              content: const Text("This action is irreversible"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    deleteStudent(student);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateColor.resolveWith((states) => Colors.red),
                    foregroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.white),
                  ),
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        );
      },
      color: Colors.red[400],
      icon: const Icon(
        Icons.delete,
      ),
    );
  }

  Widget buildStudentListItem(Student student) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (student.imgUrl != null)
            Image.network(
              student.imgUrl!,
              height: 50,
              width: 50,
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${student.firstName} ${student.lastName}"),
              Text(student.primaryContact),
            ],
          ),
          buildStudentListItemDeleteButton(student),
        ],
      ),
    );
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
          : students.isEmpty
              ? const Center(child: Text("No students"))
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (ctx, index) =>
                      buildStudentListItem(students[index]),
                ),
    );
  }
}
