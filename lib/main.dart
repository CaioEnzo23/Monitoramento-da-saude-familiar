import 'package:flutter/material.dart';
import 'package:monitoramento_saude_familiar/views/pages/Home_page.dart';

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
