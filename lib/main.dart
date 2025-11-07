import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:monitoramento_saude_familiar/models/profile_model.dart';
import 'package:monitoramento_saude_familiar/views/pages/Dash_page.dart';
import 'package:monitoramento_saude_familiar/views/pages/Home_page.dart';
import 'package:monitoramento_saude_familiar/views/pages/Teste_page.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ProfileAdapter());
  await Hive.openBox('tasksBox');
  await Hive.openBox<Profile>('profilesBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      title: "monitoramento de saude familiar",
      home: HomePage(),
    
    );
  }
}