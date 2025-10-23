import 'package:flutter/material.dart';
import 'package:monitoramento_saude_familiar/views/widgets/Calendario_widget.dart';
import 'package:monitoramento_saude_familiar/views/widgets/Carrosel_slider_widget.dart';
import 'package:monitoramento_saude_familiar/views/widgets/Botao_flutuante_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: <Widget>[
                  SizedBox(height: 50),

                  CarroselSlider(),

                  SizedBox(height: 14),

                  Calendario(),

                  SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),

        floatingActionButton: BotaoFlutuanteWidget(),
      ),
    );
  }
}
