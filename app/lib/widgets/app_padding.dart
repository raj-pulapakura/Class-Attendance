import 'package:flutter/widgets.dart';

class AppPadding extends StatelessWidget {
  const AppPadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: child,
    );
  }
}
