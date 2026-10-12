import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

/// ============================================================
///  doken — POINT D'ENTRÉE DE L'APPLICATION (WIDGET ROOT)
/// ============================================================
class dokenApp extends StatelessWidget {
  const dokenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
