import 'package:app/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddStudentForm extends StatefulWidget {
  const AddStudentForm({super.key});

  @override
  State<AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final primaryContactController = TextEditingController();
  final secondaryContactController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    primaryContactController.dispose();
    secondaryContactController.dispose();
    super.dispose();
  }

  String? validateTextField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invalid';
    }
    return null;
  }

  onSubmit() async {
    // validate form fields
    if (formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adding student to database')),
      );
    }

    // initialize firestore
    final db = FirebaseFirestore.instance;

    // send request to add student
    await db.collection("students").add({
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "primaryContact": primaryContactController.text,
      "secondaryContact": secondaryContactController.text,
      "user": Auth().currentUser?.email,
    });

    // display snackbar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Added ${firstNameController.text} ${lastNameController.text} to database'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: firstNameController,
            decoration: const InputDecoration(labelText: "First Name"),
            validator: validateTextField,
          ),
          TextFormField(
            controller: lastNameController,
            decoration: const InputDecoration(labelText: "Last Name"),
            validator: validateTextField,
          ),
          TextFormField(
            controller: primaryContactController,
            decoration: const InputDecoration(labelText: "Primary contact"),
            validator: validateTextField,
          ),
          TextFormField(
            controller: secondaryContactController,
            decoration: const InputDecoration(labelText: "Secondary contact"),
            validator: validateTextField,
          ),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }
}
