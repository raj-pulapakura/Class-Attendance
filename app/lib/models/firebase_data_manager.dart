import 'dart:io';

import 'package:app/models/auth.dart';
import 'package:app/models/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseDataManager {
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

    // update student document with img url
    await db.collection("students").doc(studentID).update(
      {"imgUrl": downloadUrl},
    );
  }

  static void deleteStudentById(String studentId) async {
    // delete student document from firestore
    final db = FirebaseFirestore.instance;
    await db.collection("students").doc(studentId).delete();

    // delete studeng image from firebase storage
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child(studentId);
    await imageRef.delete();
  }
}
