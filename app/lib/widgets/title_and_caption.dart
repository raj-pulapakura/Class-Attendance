import 'package:app/widgets/margin.dart';
import 'package:flutter/material.dart';

class TitleAndCaption extends StatelessWidget {
  const TitleAndCaption({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Margin(
          margin: const EdgeInsets.only(bottom: 10),
          child: Text(
            "Class Attendance",
            style: theme.textTheme.displaySmall!
                .copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ),
        // Text(
        //   "Your AI attendance partner.",
        //   style: theme.textTheme.bodyLarge!.copyWith(fontSize: 16),
        // )
      ],
    );
  }
}
