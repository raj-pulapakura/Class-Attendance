import 'package:app/utils/sendGetStudentsRequest.dart';
import 'package:app/widgets/student_list_item.dart';
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

  @override
  void initState() {
    sendGetStudentsRequest().then((fetchedStudents) {
      setState(() {
        students = fetchedStudents;
      });
      setState(() {
        loadingStudents = false;
      });
    });
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
