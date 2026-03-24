import 'package:app/router/router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  runApp(
    ShadcnApp.router(
      scaling: const AdaptiveScaling(0.95),
      theme: ThemeData(
        colorScheme: ColorSchemes.lightZinc.sky,
        density: .defaultDensity,
        surfaceOpacity: 0.1,
        surfaceBlur: 12.0,
        radius: 1,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    ),
  );
}
