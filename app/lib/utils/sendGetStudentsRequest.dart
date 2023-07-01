import 'dart:convert';
import 'dart:io';
import 'package:app/classes/student.dart';
import 'package:http/http.dart' as http;

Future<List<Student>> sendGetStudentsRequest() async {
  final response = await http.post(
    Uri.parse("https://r7qkm7j2mk.execute-api.ap-southeast-2.amazonaws.com/"),
    headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    },
    body: json.encode({
      "query": r"""
        query GetStudents {
            students {
                student_id
                first_name
                last_name
                primary_contact
                secondary_contact
            }
        }
        """,
    }),
  );

  final responseData = json.decode(response.body)["data"]["students"];

  final List<Student> students = responseData
      .map<Student>(
        (student) => Student(
          student_id: student["student_id"],
          first_name: student["first_name"],
          last_name: student["last_name"],
          primary_contact: student["primary_contact"],
          secondary_contact: student["secondary_contact"],
        ),
      )
      .toList();

  return students;
}
