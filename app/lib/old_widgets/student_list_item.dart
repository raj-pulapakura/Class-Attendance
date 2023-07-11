import 'package:app/models/firebase_data_manager.dart';
import 'package:app/models/student.dart';
import 'package:app/old_screens/student_view.dart';
import 'package:flutter/material.dart';

class StudentListItem extends StatelessWidget {
  const StudentListItem({
    super.key,
    required this.student,
    this.viewStudentOnClick = true,
  });

  final Student student;
  final bool viewStudentOnClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: viewStudentOnClick
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) {
                  return StudentView(student: student);
                }),
              );
            }
          : () {},
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              blurStyle: BlurStyle.outer,
              color: Colors.grey,
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
                Text(
                  "Primary contact: ${student.primaryContact}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StudentAttendanceListItem extends StatefulWidget {
  const StudentAttendanceListItem({
    super.key,
    required this.student,
    this.onMarkStudentAsPresentButtonClicked,
    this.onMarkStudentAsAbsentButtonClicked,
    this.displayIcon = false,
  });

  final Student student;
  final void Function()? onMarkStudentAsPresentButtonClicked;
  final void Function()? onMarkStudentAsAbsentButtonClicked;
  final bool displayIcon;

  @override
  State<StudentAttendanceListItem> createState() =>
      _StudentAttendanceListItemState();
}

class _StudentAttendanceListItemState extends State<StudentAttendanceListItem> {
  Widget buildAttendanceMarker() {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final studentIsPresent = snapshot.data!;

        if (studentIsPresent) {
          return IconButton(
            onPressed: widget.onMarkStudentAsAbsentButtonClicked,
            icon: const Icon(Icons.beach_access),
          );
        } else {
          return IconButton(
            onPressed: widget.onMarkStudentAsPresentButtonClicked,
            icon: const Icon(Icons.check),
          );
        }
      },
      future: FirebaseDataManager.isMarkedAsPresent(widget.student.studentID!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            blurStyle: BlurStyle.outer,
            color: Colors.grey,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.student.imgUrl != null)
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: Hero(
                tag: "${widget.student.studentID!}-image",
                child: Image.network(
                  widget.student.imgUrl!,
                  height: 50,
                  width: 50,
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: "${widget.student.studentID!}-fullname",
                child: Text(
                  "${widget.student.firstName} ${widget.student.lastName}",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                "Primary contact: ${widget.student.primaryContact}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (widget.displayIcon) buildAttendanceMarker(),
        ],
      ),
    );
  }
}
