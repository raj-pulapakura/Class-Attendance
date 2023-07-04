import 'dart:io';

import 'package:app/models/auth.dart';
import 'package:app/models/model_service.dart';
import 'package:app/models/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseDataManager {
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
