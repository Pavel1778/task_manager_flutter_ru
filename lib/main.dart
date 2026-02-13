import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'task_screen.dart';
import 'theme_provider.dart';

void main() => runApp(const TaskManagerApp());

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});
  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  final _tp = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _tp.loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _tp,
      builder: (c, _) => MaterialApp(
        title: 'Менеджер задач',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ru'),
        localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        supportedLocales: const [Locale('ru')],
        theme: ThemeData(brightness: Brightness.light, primarySwatch: Colors.blue),
        darkTheme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
        themeMode: _tp.isDark ? ThemeMode.dark : ThemeMode.light,
        home: TaskScreen(themeProvider: _tp),
      ),
    );
  }
}
