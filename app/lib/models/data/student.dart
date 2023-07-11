class Student {
  const Student({
    required this.id,
    this.classId,
    required this.firstName,
    this.lastName,
    this.standard,
    this.phone,
    this.email,
    this.imgURL,
  });

  final String id;
  final String? classId;
  final String firstName;
  final String? lastName;
  final String? standard;
  final num? phone;
  final String? email;
  final String? imgURL;
}
