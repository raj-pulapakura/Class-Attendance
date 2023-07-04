import 'package:flutter/material.dart';

import '../widgets/add_student_form.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({
    super.key,
  });

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  @override
  void initState() {
    super.initState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new student"),
      ),
      body: const AddStudentForm(),
    );
  }
}
