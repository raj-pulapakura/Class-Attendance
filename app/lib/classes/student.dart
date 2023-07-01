class Student {
  const Student({
    this.student_id,
    required this.first_name,
    required this.last_name,
    required this.primary_contact,
    required this.secondary_contact,
  });

  final String? student_id;
  final String first_name;
  final String last_name;
  final String primary_contact;
  final String secondary_contact;
}

class AddStudentResponse {
  const AddStudentResponse({
    required this.code,
    required this.message,
    required this.success,
    required this.student,
  });

  final int code;
  final String message;
  final bool success;
  final Student student;
}
