import 'package:app/classes/student.dart';
import 'package:flutter/material.dart';

class StudentListItem extends StatelessWidget {
  const StudentListItem({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name: ${student.first_name} ${student.last_name}"),
          Text("Primary contact: ${student.primary_contact}"),
          Text("Secondary contact: ${student.secondary_contact}"),
        ],
      ),
    );
  }
}
