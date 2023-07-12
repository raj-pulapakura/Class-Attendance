import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PromoItem extends StatelessWidget {
  const PromoItem({
    super.key,
    required this.text,
    required this.iconPath,
  });

  final String text;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: SvgPicture.asset(
            iconPath,
          ),
        ),
        const Flexible(
          flex: 1,
          child: SizedBox(width: 40),
        ),
        Flexible(
          flex: 4,
          child: Text(
            text,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
