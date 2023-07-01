import 'dart:convert';
import 'dart:io';
import 'package:app/classes/student.dart';
import 'package:http/http.dart' as http;

Future<AddStudentResponse> sendAddStudentRequest(String firstName,
    String lastName, String primaryContact, String secondaryContact) async {
  final response = await http.post(
    Uri.parse("https://r7qkm7j2mk.execute-api.ap-southeast-2.amazonaws.com/"),
    headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    },
    body: json.encode({
      "query": r"""
        mutation AddStudent($first_name: String!, $last_name: String!, $primary_contact: String!, $secondary_contact: String!) {
            addStudent(first_name: $first_name, last_name: $last_name, primary_contact: $primary_contact, secondary_contact: $secondary_contact) {
                code
                message
                success
                student {
                    student_id,
                    first_name,
                    last_name,
                    primary_contact,
                    secondary_contact
                }
            }
        }
        """,
      "variables": {
        "first_name": firstName,
        "last_name": lastName,
        "primary_contact": primaryContact,
        "secondary_contact": secondaryContact,
      },
    }),
  );

  final responseData = json.decode(response.body)["data"]["addStudent"];

  final AddStudentResponse addStudentResponse = AddStudentResponse(
    code: responseData["code"],
    message: responseData["message"],
    success: responseData["success"],
    student: Student(
      first_name: responseData["student"]["first_name"],
      last_name: responseData["student"]["last_name"],
      primary_contact: responseData["student"]["primary_contact"],
      secondary_contact: responseData["student"]["secondary_contact"],
    ),
  );

  return addStudentResponse;
}
