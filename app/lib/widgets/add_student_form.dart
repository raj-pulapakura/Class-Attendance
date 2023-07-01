import 'package:app/utils/sendAddStudentRequest.dart';
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

    final addStudentResponse = await sendAddStudentRequest(
      firstNameController.text,
      lastNameController.text,
      primaryContactController.text,
      secondaryContactController.text,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Added ${addStudentResponse.student.first_name} ${addStudentResponse.student.last_name} to database'),
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
            decoration: InputDecoration(labelText: "First Name"),
            validator: validateTextField,
          ),
          TextFormField(
            controller: lastNameController,
            decoration: InputDecoration(labelText: "Last Name"),
            validator: validateTextField,
          ),
          TextFormField(
            controller: primaryContactController,
            decoration: InputDecoration(labelText: "Primary contact"),
            validator: validateTextField,
          ),
          TextFormField(
            controller: secondaryContactController,
            decoration: InputDecoration(labelText: "Secondary contact"),
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
