import 'package:flutter/material.dart';
import 'package:monitoramento_saude_familiar/views/pages/dash_page.dart';
import 'package:monitoramento_saude_familiar/views/pages/home_page.dart';

void main(List<String> args) {
  runApp(AppWidet());
}

class AppWidet extends StatelessWidget {
  const AppWidet({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      title: "monitoramento de saude familiar",
      home: HomePage(),
    );
  }
}
