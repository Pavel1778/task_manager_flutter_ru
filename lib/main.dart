import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models.dart';
import 'home_screen.dart';
import 'notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});
  @override State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _tm = TaskManager();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _tm.load().then((_) => setState(() => _ready = true));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _tm,
    builder: (_, __) => MaterialApp(
      title: 'Менеджер задач',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ru'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru')],
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _tm.isDark ? ThemeMode.dark : ThemeMode.light,
      home: _ready
        ? HomeScreen(tm: _tm)
        : const Scaffold(body: Center(child: CircularProgressIndicator())),
    ),
  );
}
