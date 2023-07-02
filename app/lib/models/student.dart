class Student {
  const Student({
    this.studentID,
    this.imgUrl,
    required this.user,
    required this.firstName,
    required this.lastName,
    required this.primaryContact,
    required this.secondaryContact,
  });

  final String user;
  final String? studentID;
  final String? imgUrl;
  final String firstName;
  final String lastName;
  final String primaryContact;
  final String secondaryContact;
}
