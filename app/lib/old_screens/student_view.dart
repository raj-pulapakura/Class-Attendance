import 'package:app/models/firebase_data_manager.dart';
import 'package:app/old_widgets/edit_student_image_button.dart';
import 'package:app/old_widgets/edit_student_info.dart';
import 'package:flutter/material.dart';

import '../models/student.dart';

class StudentView extends StatefulWidget {
  const StudentView({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  late Student loadedStudent;

  @override
  void initState() {
    super.initState();
    loadedStudent = widget.student;
  }

  void loadStudent() {
    FirebaseDataManager.getStudentById(loadedStudent.studentID!).then(
      (Student? possibleStudent) {
        if (possibleStudent != null) {
          setState(() {
            loadedStudent = possibleStudent;
          });
        }
      },
    );
  }

  Future<void> deleteStudent() async {
    // delete student and all related data (including student image)
    FirebaseDataManager.deleteStudentById(loadedStudent.studentID!);

    // notify user via snackbar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Deleted student"),
        ),
      );
    }
  }

  void exit() {
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Widget buildPopupMenu() {
    return PopupMenuButton(
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            child: const Text("Edit"),
            onTap: () {
              Scaffold.of(context).showBottomSheet(
                (context) {
                  return Container(
                    margin: const EdgeInsets.all(20),
                    child: EditStudentInfoForm(
                      student: loadedStudent,
                      onClose: loadStudent,
                    ),
                  );
                },
              );
            },
          ),
          PopupMenuItem(
            child: const Text("Delete"),
            onTap: () {
              Scaffold.of(context).showBottomSheet(
                (context) {
                  return Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Are you sure you want to delete the record for ${loadedStudent.firstName} ${loadedStudent.lastName}?",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 30),
                          child: const Text("This action is irreversible."),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                await deleteStudent();
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                                exit();
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.red),
                                foregroundColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.white),
                              ),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ];
      },
    );
  }

  Widget buildStudentInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Student Information",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              buildPopupMenu(),
            ],
          ),
        ),
        Text("First Name: ${loadedStudent.firstName}"),
        Text("Last Name: ${loadedStudent.lastName}"),
        Text("Primary contact: ${loadedStudent.primaryContact}"),
        Text("Secondary contact: ${loadedStudent.secondaryContact}"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: "${loadedStudent.studentID!}-fullname",
          child: Text(
            "${loadedStudent.firstName} ${loadedStudent.lastName}",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              Hero(
                tag: "${loadedStudent.studentID!}-image",
                child: Image.network(loadedStudent.imgUrl!),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: EditStudentImageButton(
                  studentID: loadedStudent.studentID!,
                  onClose: loadStudent,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: buildStudentInfoSection(context),
          ),
        ],
      ),
    );
  }
}
