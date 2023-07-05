import 'package:app/models/firebase_data_manager.dart';
import 'package:app/models/student.dart';
import 'package:app/utils/datetime_utils.dart';
import 'package:app/widgets/student_list_item.dart';
import 'package:flutter/material.dart';

class TodaysAttendancePage extends StatefulWidget {
  const TodaysAttendancePage({super.key});

  static const presentTab = 0;
  static const absentTab = 1;

  @override
  State<TodaysAttendancePage> createState() => _TodaysAttendancePageState();
}

class _TodaysAttendancePageState extends State<TodaysAttendancePage>
    with TickerProviderStateMixin {
  List<Student>? presentStudents;
  List<Student>? absentStudents;
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    FirebaseDataManager.createTodaysAttendanceRecord().then((_) {
      updatePresentStudentsState();
      updateAbsentStudentsState();
    });
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  Future<void> updatePresentStudentsState() async {
    final students = await FirebaseDataManager.getStudentsWhoArePresentOrAbsent(
        StudentStatus.present);

    setState(() {
      presentStudents = students;
    });
  }

  Future<void> updateAbsentStudentsState() async {
    final students = await FirebaseDataManager.getStudentsWhoArePresentOrAbsent(
        StudentStatus.absent);

    setState(() {
      absentStudents = students;
    });
  }

  Future<void> markStudentAsPresentAndUpdateUI(String studentID) async {
    await FirebaseDataManager.markStudentAsPresent(studentID);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Marked student as present"),
        ),
      );
    }
    await updatePresentStudentsState();
    await updateAbsentStudentsState();
    tabController.animateTo(TodaysAttendancePage.presentTab);
  }

  Future<void> markStudentAsAbsentAndUpdateUI(String studentID) async {
    await FirebaseDataManager.markStudentAsAbsent(studentID);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Marked student as absent"),
        ),
      );
    }
    await updatePresentStudentsState();
    await updateAbsentStudentsState();
    tabController.animateTo(TodaysAttendancePage.absentTab);
  }

  Widget buildPresentStudentsTab() {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return const Tab(
          icon: Icon(Icons.check),
          text: "Present",
        );
      },
      onAccept: (studentID) async {
        final bool studentIsPresent =
            await FirebaseDataManager.isMarkedAsPresent(studentID);

        if (studentIsPresent && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Student is already marked as present"),
            ),
          );
          return;
        }

        await markStudentAsPresentAndUpdateUI(studentID);
      },
    );
  }

  Widget buildPresentStudentsView() {
    return presentStudents == null
        ? const Center(
            child: Text("Loading..."),
          )
        : presentStudents!.isEmpty
            ? const Center(child: Text("No students have arrived today!"))
            : ListView(
                children: presentStudents!
                    .map(
                      (student) => LongPressDraggable<String>(
                        data: student.studentID,
                        feedback: StudentAttendanceListItem(
                          student: student,
                        ),
                        child: StudentAttendanceListItem(
                          student: student,
                          displayIcon: true,
                          onMarkStudentAsPresentButtonClicked: () {
                            markStudentAsPresentAndUpdateUI(student.studentID!);
                          },
                          onMarkStudentAsAbsentButtonClicked: () {
                            markStudentAsAbsentAndUpdateUI(student.studentID!);
                          },
                        ),
                      ),
                    )
                    .toList(),
              );
  }

  Widget buildAbsentStudentsTab() {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return const Tab(
          icon: Icon(Icons.beach_access),
          text: "Absent",
        );
      },
      onAccept: (studentID) async {
        final bool studentIsPresent =
            await FirebaseDataManager.isMarkedAsPresent(studentID);

        if (!studentIsPresent && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Student is already marked as absent"),
            ),
          );
          return;
        }

        await markStudentAsAbsentAndUpdateUI(studentID);
      },
    );
  }

  Widget buildAbsentStudentsView() {
    return absentStudents == null
        ? const Center(
            child: Text("Loading..."),
          )
        : absentStudents!.isEmpty
            ? const Center(child: Text("Looks like everyone's present"))
            : ListView(
                children: absentStudents!
                    .map(
                      (student) => LongPressDraggable<String>(
                        data: student.studentID,
                        feedback: StudentAttendanceListItem(
                          student: student,
                        ),
                        child: StudentAttendanceListItem(
                          student: student,
                          displayIcon: true,
                          onMarkStudentAsPresentButtonClicked: () {
                            markStudentAsPresentAndUpdateUI(student.studentID!);
                          },
                          onMarkStudentAsAbsentButtonClicked: () {
                            markStudentAsAbsentAndUpdateUI(student.studentID!);
                          },
                        ),
                      ),
                    )
                    .toList(),
              );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(DateTimeUtils.getPrettyDate()),
          bottom: TabBar(
            controller: tabController,
            tabs: [
              buildPresentStudentsTab(),
              buildAbsentStudentsTab(),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            buildPresentStudentsView(),
            buildAbsentStudentsView(),
          ],
        ),
      ),
    );
  }
}
