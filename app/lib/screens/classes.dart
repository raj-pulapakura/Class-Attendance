import 'package:app/main.dart';
import 'package:app/widgets/margin.dart';
import 'package:flutter/material.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          shrinkWrap: true,
          children: [
            Text(
              "Classes",
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Margin(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Classes allow you to group students and take attendance.",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: colourPalette.neutralShade.shade100,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Margin(
                  margin: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    "Let's make your first one.",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: colourPalette.neutralShade.shade100,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style:
                      Theme.of(context).elevatedButtonTheme.style!.copyWith(),
                  child: const Text("Create class"),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
