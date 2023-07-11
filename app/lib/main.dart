import 'package:app/colour_palette.dart';
import 'package:app/old_screens/home.dart';
import 'package:app/screens/login_register.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:flutter/services.dart';
import 'models/auth.dart';

late List<CameraDescription> _cameras;

const colourPalette = ColourPalette(
  primary: PrimarySwatch(
    primary50: Color.fromRGBO(242, 245, 255, 1.0),
    primary100: Color.fromRGBO(216, 224, 252, 1.0),
    primary200: Color.fromRGBO(177, 193, 250, 1.0),
    primary300: Color.fromRGBO(139, 161, 247, 1.0),
    primary400: Color.fromRGBO(100, 130, 245, 1.0),
    primary500: Color.fromRGBO(61, 99, 242, 1.0),
    primary600: Color.fromRGBO(49, 79, 194, 1.0),
    primary700: Color.fromRGBO(37, 59, 145, 1.0),
    primary800: Color.fromRGBO(24, 40, 97, 1.0),
    primary900: Color.fromRGBO(12, 20, 48, 1.0),
  ),
  secondary: SecondarySwatch(
    secondary100: Color.fromRGBO(255, 231, 209, 1.0),
    secondary200: Color.fromRGBO(255, 207, 163, 1.0),
    secondary300: Color.fromRGBO(255, 183, 117, 1.0),
    secondary400: Color.fromRGBO(255, 159, 71, 1.0),
    secondary500: Color.fromRGBO(255, 135, 25, 1.0),
    secondary600: Color.fromRGBO(204, 108, 20, 1.0),
    secondary700: Color.fromRGBO(153, 81, 15, 1.0),
    secondary800: Color.fromRGBO(102, 54, 10, 1.0),
    secondary900: Color.fromRGBO(51, 27, 5, 1.0),
  ),
  accent: AccentSwatch(
    accent100: Color.fromRGBO(254, 224, 231, 1.0),
    accent200: Color.fromRGBO(254, 194, 208, 1.0),
    accent300: Color.fromRGBO(253, 163, 184, 1.0),
    accent400: Color.fromRGBO(253, 133, 161, 1.0),
    accent500: Color.fromRGBO(252, 102, 137, 1.0),
    accent600: Color.fromRGBO(202, 82, 110, 1.0),
    accent700: Color.fromRGBO(151, 61, 82, 1.0),
    accent800: Color.fromRGBO(101, 41, 55, 1.0),
    accent900: Color.fromRGBO(50, 20, 27, 1.0),
  ),
  neutralTint: NeutralTintSwatch(
    tint100: Color.fromRGBO(245, 246, 250, 1.0),
    tint200: Color.fromRGBO(230, 233, 242, 1.0),
    tint300: Color.fromRGBO(195, 200, 217, 1.0),
    tint400: Color.fromRGBO(173, 180, 204, 1.0),
    tint500: Color.fromRGBO(153, 161, 191, 1.0),
    tint600: Color.fromRGBO(134, 143, 178, 1.0),
  ),
  neutralShade: NeutralShadeSwatch(
    shade100: Color.fromRGBO(71, 78, 102, 1.0),
    shade200: Color.fromRGBO(67, 72, 89, 1.0),
    shade300: Color.fromRGBO(61, 64, 77, 1.0),
    shade400: Color.fromRGBO(54, 56, 64, 1.0),
    shade500: Color.fromRGBO(36, 37, 38, 1.0),
  ),
  danger: DangerSwatch(
    danger100: Color.fromRGBO(252, 211, 211, 1.0),
    danger200: Color.fromRGBO(249, 168, 168, 1.0),
    danger300: Color.fromRGBO(245, 124, 124, 1.0),
    danger400: Color.fromRGBO(242, 81, 81, 1.0),
    danger500: Color.fromRGBO(239, 37, 37, 1.0),
    danger600: Color.fromRGBO(191, 30, 30, 1.0),
    danger700: Color.fromRGBO(143, 22, 22, 1.0),
    danger800: Color.fromRGBO(96, 15, 15, 1.0),
    danger900: Color.fromRGBO(48, 7, 7, 1.0),
  ),
  success: SuccessSwatch(
    success100: Color.fromRGBO(216, 247, 219, 1.0),
    success200: Color.fromRGBO(177, 239, 183, 1.0),
    success300: Color.fromRGBO(137, 232, 147, 1.0),
    success400: Color.fromRGBO(98, 224, 111, 1.0),
    success500: Color.fromRGBO(59, 216, 75, 1.0),
    success600: Color.fromRGBO(47, 173, 60, 1.0),
    success700: Color.fromRGBO(35, 130, 45, 1.0),
    success800: Color.fromRGBO(24, 86, 30, 1.0),
    success900: Color.fromRGBO(12, 43, 15, 1.0),
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AttendEase',
      theme: ThemeData(
        fontFamily: "Montserrat",
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: colourPalette.primary.primary500,
          onPrimary: const Color.fromRGBO(255, 255, 255, 1.0),
          secondary: colourPalette.secondary.secondary500,
          onSecondary: const Color.fromRGBO(0, 0, 0, 1.0),
          error: colourPalette.danger.danger500,
          onError: colourPalette.danger.danger800,
          background: colourPalette.neutralTint.tint100,
          onBackground: colourPalette.neutralShade.shade400,
          surface: colourPalette.neutralTint.tint200,
          onSurface: colourPalette.neutralShade.shade500,
          shadow: const Color.fromRGBO(0, 0, 0, .5),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 50,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
          ),
          displayMedium: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 40,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
          ),
          displaySmall: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 32,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
          ),
          headlineLarge: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 32,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
          ),
          headlineMedium: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 28,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
          ),
          headlineSmall: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
          ),
          titleLarge: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            fontFamily: "Montserrat",
          ),
          titleMedium: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: "Montserrat",
            letterSpacing: 0.15,
          ),
          titleSmall: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: "Montserrat",
            letterSpacing: 0.1,
          ),
          labelLarge: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
            letterSpacing: 0.1,
          ),
          labelMedium: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
            letterSpacing: 0.5,
          ),
          labelSmall: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
            letterSpacing: 0.5,
          ),
          bodyLarge: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
            letterSpacing: 0.15,
          ),
          bodyMedium: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
            letterSpacing: 0.25,
          ),
          bodySmall: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
            letterSpacing: 0.4,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusColor: colourPalette.primary.primary500,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 17,
          ),
          labelStyle: TextStyle(
            color: colourPalette.neutralShade.shade400,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
            letterSpacing: 0.5,
          ),
          floatingLabelStyle: TextStyle(
            color: colourPalette.primary.primary500,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat",
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(5),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor:
                MaterialStateProperty.all(colourPalette.primary.primary500),
            overlayColor:
                MaterialStateProperty.all(colourPalette.primary.primary600),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 20,
              ),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            textStyle: MaterialStateProperty.all(
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: "Montserrat",
              ),
            ),
          ),
        ),
      ),
      home: StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MyHomePage(
              title: "",
              cameras: _cameras,
            );
          } else {
            return const LoginRegisterScreen();
          }
        },
      ),
    );
  }
}
