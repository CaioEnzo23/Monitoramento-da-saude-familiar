import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:monitoramento_saude_familiar/views/pages/Dash_page.dart';
import 'package:monitoramento_saude_familiar/views/pages/Home_page.dart';
import 'package:monitoramento_saude_familiar/views/pages/Teste_page.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('tasksBox');
  runApp(AppWidet());
}

class AppWidet extends StatelessWidget {
  const AppWidet({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      title: "monitoramento de saude familiar",
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gráfico de Clima'),
          backgroundColor: Colors.black,
        ),
        body: const SingleChildScrollView(child: LineChartSample13()),
      ),
    );
  }
}