import 'package:flutter/material.dart';
import 'database/hive_database.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kakanin Consignment',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
            devicePixelRatio: 1.0,
          ),
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
