import 'package:app/main.dart';
import 'package:app/widgets/app_padding.dart';
import 'package:app/widgets/margin.dart';
import 'package:app/widgets/title_and_caption.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:app/models/auth.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({
    super.key,
    this.isLogin = true,
  });

  final bool isLogin;

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  String? errorMessage;
  late bool isLogin;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool passwordIsVisible = false;

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLogin;
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == "wrong-password" || e.code == "user-not-found") {
          errorMessage =
              "The password is invalid or an account with that email does not exist.";
        } else {
          errorMessage = e.message;
        }
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget buildFullNameInput() {
    return TextFormField(
      controller: fullNameController,
      textAlignVertical: TextAlignVertical.center,
      decoration: const InputDecoration(labelText: "Full Name"),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a name";
        }
        return null;
      },
    );
  }

  Widget buildEmailInput() {
    return TextFormField(
      controller: emailController,
      textAlignVertical: TextAlignVertical.center,
      decoration: const InputDecoration(labelText: "Email"),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter an email";
        }
        if (!EmailValidator.validate(value)) {
          return "Please enter a valid email";
        }
        return null;
      },
    );
  }

  Widget buildPasswordInput() {
    return TextFormField(
      controller: passwordController,
      obscureText: !passwordIsVisible,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        labelText: "Password",
        suffixIcon: IconButton(
          icon:
              Icon(passwordIsVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              passwordIsVisible = !passwordIsVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a password";
        }
        if (value.length < 8) {
          return "Password must be at least 8 characters";
        }
        return null;
      },
    );
  }

  Widget buildLoginOrRegisterButton() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(isLogin ? "No account?" : "Have an account?"),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () {
            setState(() {
              isLogin = !isLogin;
            });
          },
          child: Text(
            isLogin ? "Sign up" : "Sign in",
            style: TextStyle(color: colourPalette.primary.primary500),
          ),
        )
      ],
    );
  }

  Widget buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final isValid = formKey.currentState!.validate();

          if (!isValid) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isLogin ? "Signing in..." : "Creating account..."),
            ),
          );

          setState(() {
            errorMessage = null;
          });

          if (isLogin) {
            await signInWithEmailAndPassword();
          } else {
            await createUserWithEmailAndPassword();
          }

          if (errorMessage != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage!),
                backgroundColor: colourPalette.danger.danger400,
              ),
            );
          } else if (context.mounted) {
            if (isLogin) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("You're signed in, welcome."),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Welcome, ${fullNameController.text}"),
                ),
              );
            }

            Navigator.of(context).pop();
          }
        },
        child: Text(isLogin ? "Sign in" : "Sign up"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppPadding(
        child: Center(
          child: Form(
            key: formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const Margin(
                  margin: EdgeInsets.only(bottom: 70),
                  child: TitleAndCaption(),
                ),
                // input fields
                if (!isLogin)
                  Margin(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: buildFullNameInput(),
                  ),
                Margin(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: buildEmailInput(),
                ),
                Margin(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: buildPasswordInput(),
                ),
                // change to login or register
                Margin(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: buildLoginOrRegisterButton(),
                ),
                // submit form
                Margin(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: buildSubmitButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
