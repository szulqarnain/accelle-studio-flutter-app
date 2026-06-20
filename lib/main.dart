import 'package:flutter/material.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';

void main() => runApp(const AccelleStudioApp());

class AccelleStudioApp extends StatelessWidget {
  const AccelleStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeNotifier.instance,
      builder: (context, _) => MaterialApp.router(
        title: 'Accelle Studio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeNotifier.instance.value,
        routerConfig: appRouter,
      ),
    );
  }
}
