// main.dart - Точка входа приложения
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/theme_provider.dart';
import 'services/task_manager.dart';
import 'screens/task_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final theme = ThemeProvider();
  final tasks = TaskManager();
  // Загружаем данные до запуска UI
  await Future.wait([theme.load(), tasks.load()]);
  runApp(MyApp(theme: theme, tasks: tasks));
}

class MyApp extends StatelessWidget {
  final ThemeProvider theme;
  final TaskManager tasks;
  const MyApp({super.key, required this.theme, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: theme),
        ChangeNotifierProvider.value(value: tasks),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, tp, __) => MaterialApp(
          title: 'Менеджер Задач',
          debugShowCheckedModeBanner: false,
          // Локализации для русского календаря и виджетов дат
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ru'), Locale('en')],
          locale: const Locale('ru'),
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.grey[100],
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF121212),
            useMaterial3: true,
          ),
          themeMode: tp.isDark ? ThemeMode.dark : ThemeMode.light,
          home: const TaskScreen(),
        ),
      ),
    );
  }
}
