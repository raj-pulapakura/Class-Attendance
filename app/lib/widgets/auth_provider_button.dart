import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AuthProvider { google, microsoft, s }

class AuthProviderButton extends StatelessWidget {
  const AuthProviderButton({
    super.key,
    required this.authProvider,
    required this.onPressed,
  });

  final AuthProvider authProvider;
  final VoidCallback onPressed;

  Widget buildSvg(String assetPath) {
    return SvgPicture.asset(assetPath, width: 30, height: 30);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ElevatedButton(
      onPressed: onPressed,
      style: theme.elevatedButtonTheme.style!.copyWith(
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        elevation: MaterialStateProperty.all(0),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(
              color: colourPalette.neutralTint.tint300,
              width: 2,
            ),
          ),
        ),
        overlayColor:
            MaterialStateProperty.all(colourPalette.neutralTint.tint200),
      ),
      child: authProvider == AuthProvider.google
          ? buildSvg("assets/images/google.svg")
          : buildSvg("assets/images/microsoft.svg"),
    );

    // return Container(
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(50),
    //     border: Border.all(
    //       color: colourPalette.neutralTint.tint500,
    //       width: 1,
    //     ),
    //   ),
    //   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
    //   child: ,
    // );
  }
}
