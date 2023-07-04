import 'package:app/models/firebase_data_manager.dart';
import 'package:app/models/student.dart';
import 'package:flutter/material.dart';

class EditStudentInfoForm extends StatefulWidget {
  const EditStudentInfoForm({
    super.key,
    required this.student,
    required this.onClose,
  });

  final Student student;
  final VoidCallback onClose;

  @override
  State<EditStudentInfoForm> createState() => _EditStudentInfoFormState();
}

class _EditStudentInfoFormState extends State<EditStudentInfoForm> {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final primaryContactController = TextEditingController();
  final secondaryContactController = TextEditingController();

  @override
  void initState() {
    firstNameController.text = widget.student.firstName;
    lastNameController.text = widget.student.lastName;
    primaryContactController.text = widget.student.primaryContact;
    secondaryContactController.text = widget.student.secondaryContact;
    super.initState();
  }

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

  bool validateForm() {
    return formKey.currentState!.validate();
  }

  Future<void> submitForm() async {
    if (!validateForm()) return;

    await FirebaseDataManager.updateStudentInfo(
      widget.student.studentID!,
      firstNameController.text,
      lastNameController.text,
      primaryContactController.text,
      secondaryContactController.text,
    );

    if (context.mounted) {
      Navigator.of(context).pop();
    }

    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: submitForm,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange[400]),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: const Text("Update"),
            ),
          ),
        ],
      ),
    );
  }
}
