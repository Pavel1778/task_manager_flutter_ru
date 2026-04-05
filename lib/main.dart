import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/task_manager.dart';
import 'services/theme_provider.dart';
import 'screens/task_screen.dart';

void main() => runApp(MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => TaskManager()..load()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
  ],
  child: const MyApp(),
));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(
    builder: (context, themeProvider, _) => MaterialApp(
      title: 'Менеджер задач',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ru', 'RU'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru', 'RU')],
      theme: ThemeData(brightness: Brightness.light, primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100], useMaterial3: true),
      darkTheme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212), useMaterial3: true),
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const TaskScreen(),
    ),
  );
}

