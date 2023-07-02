class Student {
  const Student({
    required this.user,
    this.studentID,
    required this.firstName,
    required this.lastName,
    required this.primaryContact,
    required this.secondaryContact,
  });

  final String user;
  final String? studentID;
  final String firstName;
  final String lastName;
  final String primaryContact;
  final String secondaryContact;
}
