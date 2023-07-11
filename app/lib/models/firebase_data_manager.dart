import 'dart:io';

import 'package:app/models/auth.dart';
import 'package:app/models/model_service.dart';
import 'package:app/models/student.dart';
import 'package:app/utils/datetime_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

enum StudentStatus { present, absent }

class FirebaseDataManager {
  static Future<void> createTodaysAttendanceRecord() async {
    final String date = DateTimeUtils.getDateWithDashes();
    final db = FirebaseFirestore.instance;

    print("Creating today's attendance record");

    await db.collection("attendance").doc(date).set(
      {
        "studentsPresent": [],
      },
    );
  }

  static Future<bool> isMarkedAsPresent(String studentID) async {
    final String date = DateTimeUtils.getDateWithDashes();
    final db = FirebaseFirestore.instance;

    final DocumentSnapshot<Map<String, dynamic>> docData =
        await db.collection("attendance").doc(date).get();

    if (!docData.exists) {
      await FirebaseDataManager.createTodaysAttendanceRecord();
      return false;
    }

    for (final student in docData["studentsPresent"]) {
      if (student["studentID"] == studentID) return true;
    }

    return false;
  }

  static Future<List<Student>> getStudentsWhoArePresentOrAbsent(
    StudentStatus status,
  ) async {
    try {
      final String date = DateTimeUtils.getDateWithDashes();
      final db = FirebaseFirestore.instance;

      // get today's attendance record
      final DocumentSnapshot<Map<String, dynamic>> docData =
          await db.collection("attendance").doc(date).get();

      if (!docData.exists) {
        await FirebaseDataManager.createTodaysAttendanceRecord();
        if (status == StudentStatus.present) return [];
        return FirebaseDataManager.getAllStudents();
      }

      // extract the ids of students who are present
      final presentStudentIDs = docData["studentsPresent"].map(
        (rec) => rec["studentID"],
      );

      QuerySnapshot querySnapshot;

      if (status == StudentStatus.present) {
        if (presentStudentIDs.isEmpty) return [];
        // get the students who are present (i.e. their student id is in the above list)
        querySnapshot = await db
            .collection("students")
            .where(FieldPath.documentId, whereIn: presentStudentIDs)
            .get();
      } else {
        if (presentStudentIDs.isEmpty) {
          return FirebaseDataManager.getAllStudents();
        }
        // get the students who are absent (i.e. their student id is not in the above list)
        querySnapshot = await db
            .collection("students")
            .where(FieldPath.documentId, whereNotIn: presentStudentIDs)
            .get();
      }

      return querySnapshot.docs.map((docSnapshot) {
        final Map<String, dynamic> data =
            docSnapshot.data() as Map<String, dynamic>;

        return Student(
          user: data["user"],
          firstName: data["firstName"],
          lastName: data["lastName"],
          primaryContact: data["primaryContact"],
          secondaryContact: data["secondaryContact"],
          imgUrl: data["imgUrl"],
          embeddings: data["embeddings"],
          studentID: docSnapshot.id,
        );
      }).toList();
    } catch (e) {
      print("Error getting students: ${e}");
      return [];
    }
  }

  static Future<void> markStudentAsPresent(String studentID) async {
    final db = FirebaseFirestore.instance;

    final DateTime now = DateTimeUtils.getCurrentTimeStamp();
    final String date = DateTimeUtils.getDateWithDashes();

    final DocumentSnapshot<Map<String, dynamic>> docData =
        await db.collection("attendance").doc(date).get();

    if (!docData.exists) {
      // if the document doesn't exist, then create a new one with the student
      await db.collection("attendance").doc(date).set(
        {
          "studentsPresent": [
            {
              "studentID": studentID,
              "timestamp": now,
            },
          ]
        },
      );
    } else {
      // if the document does exist, update the existing list of present students
      // FieldValue.arrayUnion allows you to append to an array in firestore
      await db.collection("attendance").doc(date).update(
        {
          "studentsPresent": FieldValue.arrayUnion(
            [
              {
                "studentID": studentID,
                "timestamp": now,
              },
            ],
          )
        },
      );
    }
  }

  static Future<void> markStudentAsAbsent(String studentID) async {
    final db = FirebaseFirestore.instance;

    final date = DateTimeUtils.getDateWithDashes();

    final DocumentSnapshot<Map<String, dynamic>> docData =
        await db.collection("attendance").doc(date).get();

    if (!docData.exists) {
      await FirebaseDataManager.createTodaysAttendanceRecord();
    }

    final student = docData["studentsPresent"].firstWhere(
      (element) => element["studentID"] == studentID,
    );

    if (docData.exists) {
      // if the document exists, then remove the student from the present students list
      await db.collection("attendance").doc(date).update(
        {
          "studentsPresent": FieldValue.arrayRemove(
            [
              {
                "studentID": studentID,
                "timestamp": student["timestamp"],
              },
            ],
          )
        },
      );
    }
  }

  static Future<Student?> getStudentById(String studentID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection("students")
          .doc(studentID)
          .get();

      Map<String, dynamic> data = doc.data()!;

      return Student(
        user: data["user"],
        firstName: data["firstName"],
        lastName: data["lastName"],
        primaryContact: data["primaryContact"],
        secondaryContact: data["secondaryContact"],
        imgUrl: data["imgUrl"],
        embeddings: data["embeddings"],
        studentID: studentID,
      );
    } catch (e) {
      print("Error completing: $e");
      return null;
    }
  }

  static Future<List<Student>> getAllStudents() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("students")
          .where("user", isEqualTo: Auth().currentUser?.email)
          .get();

      return querySnapshot.docs.map((docSnapshot) {
        final Map<String, dynamic> data =
            docSnapshot.data() as Map<String, dynamic>;

        return Student(
          user: data["user"],
          firstName: data["firstName"],
          lastName: data["lastName"],
          primaryContact: data["primaryContact"],
          secondaryContact: data["secondaryContact"],
          imgUrl: data["imgUrl"],
          embeddings: data["embeddings"],
          studentID: docSnapshot.id,
        );
      }).toList();
    } catch (e) {
      print("Error completing: $e");
      return [];
    }
  }

  static Future<void> addStudent({
    required String firstName,
    required String lastName,
    required String primaryContact,
    required String secondaryContact,
    required File image,
  }) async {
    final db = FirebaseFirestore.instance;

    // add student to firestore
    final docRef = await db.collection("students").add({
      "firstName": firstName,
      "lastName": lastName,
      "primaryContact": primaryContact,
      "secondaryContact": secondaryContact,
      "user": Auth().currentUser?.email,
    });

    // retrieve studentId
    final studentID = docRef.id;

    // add image to firebase storage
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child(studentID);
    await imageRef.putFile(image);

    // retreive img url for student image
    final downloadUrl = await imageRef.getDownloadURL();

    // calculate embeddings
    final faceML = ModelService();
    await faceML.initializeInterperter();
    final embeddings = await faceML.runModelForStudentImage(downloadUrl);

    // update student document with img url and embeddings
    await db.collection("students").doc(studentID).update(
      {
        "imgUrl": downloadUrl,
        "embeddings": embeddings,
      },
    );
  }

  static Future<void> deleteStudentImage(String studentId) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child(studentId);
    await imageRef.delete();
  }

  static Future<void> updateStudentInfo(
    String studentID,
    String firstName,
    String lastName,
    String primaryContact,
    String secondaryContact,
  ) async {
    final db = FirebaseFirestore.instance;
    await db.collection("students").doc(studentID).update({
      "firstName": firstName,
      "lastName": lastName,
      "primaryContact": primaryContact,
      "secondaryContact": secondaryContact,
    });
  }

  static Future<void> updateStudentImage(
    String studentId,
    File image,
  ) async {
    // delete old image
    await deleteStudentImage(studentId);

    // add new image to firebase storage
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child(studentId);
    await imageRef.putFile(image);

    // retreive img url for new image
    final downloadUrl = await imageRef.getDownloadURL();

    // calculate embeddings for new image
    final faceML = ModelService();
    await faceML.initializeInterperter();
    final embeddings = await faceML.runModelForStudentImage(downloadUrl);

    // update student document with img url and embeddings
    final db = FirebaseFirestore.instance;
    await db.collection("students").doc(studentId).update(
      {
        "imgUrl": downloadUrl,
        "embeddings": embeddings,
      },
    );
  }

  static void deleteStudentById(String studentId) async {
    // delete student document from firestore
    final db = FirebaseFirestore.instance;
    await db.collection("students").doc(studentId).delete();

    // delete student image from firebase storage
    deleteStudentImage(studentId);
  }
}
