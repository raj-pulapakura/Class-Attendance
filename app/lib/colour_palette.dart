import 'package:flutter/material.dart';

class PrimarySwatch {
  const PrimarySwatch({
    required this.primary50,
    required this.primary100,
    required this.primary200,
    required this.primary300,
    required this.primary400,
    required this.primary500,
    required this.primary600,
    required this.primary700,
    required this.primary800,
    required this.primary900,
  });

  final Color primary50;
  final Color primary100;
  final Color primary200;
  final Color primary300;
  final Color primary400;
  final Color primary500;
  final Color primary600;
  final Color primary700;
  final Color primary800;
  final Color primary900;
}

class SecondarySwatch {
  const SecondarySwatch({
    required this.secondary100,
    required this.secondary200,
    required this.secondary300,
    required this.secondary400,
    required this.secondary500,
    required this.secondary600,
    required this.secondary700,
    required this.secondary800,
    required this.secondary900,
  });

  final Color secondary100;
  final Color secondary200;
  final Color secondary300;
  final Color secondary400;
  final Color secondary500;
  final Color secondary600;
  final Color secondary700;
  final Color secondary800;
  final Color secondary900;
}

class AccentSwatch {
  const AccentSwatch({
    required this.accent100,
    required this.accent200,
    required this.accent300,
    required this.accent400,
    required this.accent500,
    required this.accent600,
    required this.accent700,
    required this.accent800,
    required this.accent900,
  });

  final Color accent100;
  final Color accent200;
  final Color accent300;
  final Color accent400;
  final Color accent500;
  final Color accent600;
  final Color accent700;
  final Color accent800;
  final Color accent900;
}

class NeutralTintSwatch {
  const NeutralTintSwatch({
    required this.tint100,
    required this.tint200,
    required this.tint300,
    required this.tint400,
    required this.tint500,
    required this.tint600,
  });

  final Color tint100;
  final Color tint200;
  final Color tint300;
  final Color tint400;
  final Color tint500;
  final Color tint600;
}

class NeutralShadeSwatch {
  const NeutralShadeSwatch({
    required this.shade100,
    required this.shade200,
    required this.shade300,
    required this.shade400,
    required this.shade500,
  });

  final Color shade100;
  final Color shade200;
  final Color shade300;
  final Color shade400;
  final Color shade500;
}

class DangerSwatch {
  const DangerSwatch({
    required this.danger100,
    required this.danger200,
    required this.danger300,
    required this.danger400,
    required this.danger500,
    required this.danger600,
    required this.danger700,
    required this.danger800,
    required this.danger900,
  });

  final Color danger100;
  final Color danger200;
  final Color danger300;
  final Color danger400;
  final Color danger500;
  final Color danger600;
  final Color danger700;
  final Color danger800;
  final Color danger900;
}

class SuccessSwatch {
  const SuccessSwatch({
    required this.success100,
    required this.success200,
    required this.success300,
    required this.success400,
    required this.success500,
    required this.success600,
    required this.success700,
    required this.success800,
    required this.success900,
  });

  final Color success100;
  final Color success200;
  final Color success300;
  final Color success400;
  final Color success500;
  final Color success600;
  final Color success700;
  final Color success800;
  final Color success900;
}

class ColourPalette {
  const ColourPalette({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.neutralTint,
    required this.neutralShade,
    required this.danger,
    required this.success,
  });

  final PrimarySwatch primary;
  final SecondarySwatch secondary;
  final AccentSwatch accent;
  final NeutralTintSwatch neutralTint;
  final NeutralShadeSwatch neutralShade;
  final DangerSwatch danger;
  final SuccessSwatch success;
}
