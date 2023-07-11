class User {
  const User({
    required this.id,
    required this.name,
    required this.classes,
    required this.students,
  });

  final String id;
  final String name;
  final List classes;
  final List students;
}
